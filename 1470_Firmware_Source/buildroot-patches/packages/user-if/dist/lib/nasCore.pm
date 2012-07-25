package nasCore;
#
# This object forms the base of all NAS function objects.
#
#	Ian Steel
#	September 2006
#
use strict;

use vars qw($g_language);

use Template;

use IO::File;
use nasLanguage qw($message);
use nasCommon;
use Service::Ethernet;
use Service::Storage;
use Service::DateText;
use Session::NAS;
use Config::IniFiles;

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	$self->{lang} =	shift || return;	# A language code
	$self->{cgi} = 	shift || return;	# A CGI object
	$self->{config}=shift || return;	# A Config::IniFiles object
	$self->{usecookie}=shift;		# Use cookies
	$self->{session}=undef;			# A Session object (see processRequest)

	return $self;
}

sub processRequest {
	# Calls the main() method in the implementing class.
	my $this=shift;
	#print "I am a $this\n";
    # If the language isn't english, then "require" the language file.
    if ( $this->{lang} ne q(en) ) {
        my $currLang = $this->{lang}."NasLanguage" ;
        eval "require $currLang" ;
    
        # copy in the new language strings
        # eg $message->{fr} = $frNasLanguage::massage->{fr};
        my $langimport = '$message->{ '.$this->{lang}.' } = $'.$currLang.'::message->{ '.$this->{lang}.' }';
        eval "$langimport";
    }
    
	if( $this->{usecookie}) {
		# Enforce the single user system by using cookies & sessions
		my $session = Session::NAS->new( nasCommon->cookieName );

		# Are there any live sessions already?
		my $sessions = Session::NAS->liveSessions();
		delete $sessions->{$session->sessionName()};	# remove my session
		if (keys %{$sessions}) {
			# There are live sessions, and not mine
			my @sessions = sort {$sessions->{$b} <=> $sessions->{$a}} keys %{$sessions};
			my $mostRecent = $sessions->{$sessions[0]};	# Top time
			my $waitTime = 300 - (time() - $mostRecent);
			my $s_or_m;
			if ($waitTime>=60) {
				# Minutes
				$waitTime = $waitTime / 60 if $waitTime;
				$waitTime = int($waitTime)+1;
				$s_or_m=nasCommon::getMessage( $this->{config}, 'eWaitTime3' );
			} else {
				# Seconds
				$s_or_m=nasCommon::getMessage( $this->{config}, 'eWaitTime2' );
			}
			$this->warning( $this->{config}, 'eTooManyUsers',
				nasCommon::getMessage( $this->{config}, 'eWaitTime1' ).
				$waitTime. $s_or_m
			);
			return;
		}
		# Store the session in this object
		$this->{session}=$session;
		$this->{session}->touch();	# Update the access time
	}

	# Call the main method in the page handler class with args for historic reasons
	$this->main(
		$this->{cgi},
		$this->{config},
	);
}


sub outputTemplate($$$) {
	my ($self, $tmplName, $vars) = @_;

	print $self->{cgi}->header(
		-cookie => ($self->{session}) ? $self->{session}->cookie() : '',
		-type => 'text/html; charset=UTF-8',
		-cache-control => 'no-cache',
	);

        my $tmpl = Template->new(       
                INCLUDE_PATH => nasCommon->nas_templates . $self->{lang} .
                ':'.nasCommon->nas_templates . 'en'
        );

	# Include the language specific text
	#
	if ( $self->{lang} eq q(en) ) {
		$vars->{lang} = $nasLanguage::message->{$self->{lang}};
	} else
	{
        my $currLang = $self->{lang}."NasLanguage" ;
        eval "require $currLang" ;
		if ($@) { debug $@ ; }
        my $langMessage = '$vars->{lang} = $' . $currLang . '::message -> {' . $self->{lang} . ' }' ;
        eval $langMessage ;
	}

	# Include data visible on ALL pages (firmware version, device name, etc)
	#
	$vars->{fr_device_name} = nasCommon->hostname;	#hostname();
	my $fd=new IO::File( nasCommon->version_file );
	my $version='';
	while( <$fd> ) {
		chomp;
		(/^(.*)$/) && ($version=$1,last);
	}

	# get workgroup
	$vars->{fr_workgroup} = `/usr/www/nbin/network_get_info.sh | grep ^WG | cut -c 4-`;

	# Determine drive status
	my $storage = new Service::Storage( '/shares/internal' );
	my $driveStatus = $storage->driveStatus( $self->{config} );
	
	$vars->{fr_firmware} = $version;
	$vars->{fr_drive_status} = $driveStatus;
    
    # form a date
	my $tz = $self->{config}->val( 'general','timezone' ) || 'America/Boise';
    my $dt = DateTime->now(time_zone => $tz);
    my $day = Service::DateText::getDay($self->{config}, $dt);
    my $month = Service::DateText::getMonth($self->{config}, $dt);
	$vars->{fr_datetime} = $day.' '.$dt->day_of_month.' '.$month.' '.$dt->year.' / '.$dt->strftime('%H:%M').' '.$dt->time_zone_short_name;

	$vars->{fr_username} = $ENV{REMOTE_USER};
    
	# System Summary Panel
	#

	# Storage
	#
	# Internal
	my $storage = new Service::Storage( '/shares/internal' );
	$vars->{fr_str_total} = nasCommon->commify( $storage->total() ).'K';
	$vars->{fr_str_available} = nasCommon->commify( $storage->available() ).'K';
	$vars->{fr_str_perc_free} = $storage->pc_free();
	# External
	my $storage = new Service::Storage( '/shares/external' );
	$vars->{fr_ext_total} = nasCommon->commify( $storage->total() ).'K';
	$vars->{fr_ext_available} = nasCommon->commify( $storage->available() ).'K';
	$vars->{fr_ext_perc_free} = $storage->pc_free();

	# Network
	#
	my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
	my $workgroup;
	$workgroup = $smbConf->val('global', 'workgroup') if ($smbConf);

	my $eth = new Service::Ethernet( 'eth0' );
	$vars->{fr_net_speed} = 	$eth->speed();
	$vars->{fr_net_ip_addr} = 	$eth->address();
	$vars->{fr_net_def_gw} = 	$eth->gw();
	$vars->{fr_net_workgrp} = 	$workgroup;

	# Add the main part of the page
	#
	$vars->{mainBit} = $tmplName;
	$tmpl->process('mainStruct.tpl', $vars )
			|| die "Template Build Failed: " . $tmpl->error();
	print "\r\n";

}

# Language capable template output but without being embedded within the overall template
#
# Mainly used with Ajax to build parts of a larger page
#
sub outputSubTemplate($$$) {

	my ($self, $tmplName, $vars) = @_;

	print $self->{cgi}->header(
		-cookie => ($self->{session}) ? $self->{session}->cookie() : '',
		-type => 'text/html',
		-cache-control => 'no-cache',
	);

	my $tmpl = Template->new(	
		INCLUDE_PATH => nasCommon->nas_templates . $self->{lang} . 
		':'.nasCommon->nas_templates . 'en'	
	);

	# Include the language specific text
	#
	if ( $self->{lang} eq q(en) ) {
		$vars->{lang} = $nasLanguage::message->{$self->{lang}};
	} else {
        my $currLang = $self->{lang}."NasLanguage" ;
        eval "require $currLang" ;
        my $langMessage = '$vars->{lang} = $' . $currLang . '::message -> {' . $self->{lang} . ' }' ;
        eval $langMessage ;
	}
	
	$tmpl->process($tmplName, $vars )
			|| die "Template Build Failed: " . $tmpl->error();

	print "\r\n";
}

sub fatalError {

	my ($self, $config, $errCode, $message) = @_;
	$self->outputTemplate('fatalError.tpl', { 
		errCode => $errCode,
		errMessage => nasCommon::getMessage($config, $errCode),
		internalError => $message,
	});

}

sub warning {
	my ($self, $config, $errCode, $message) = @_;
	$self->outputTemplate('warning.tpl', { 
		errCode => $errCode,
		errMessage => nasCommon::getMessage($config, $errCode),
		message => $message,
	});
}

#
# Returns an arrayref. Each element is a hash describing an individual share.
#
sub getShares($$) {

  my ($self, $config) = @_;

  unless (sudo("$nbin/chmod.sh 0666 " . nasCommon->smb_conf )) {
    $self->fatalError($config, 'f00020');
    return;
  }

  # Determine the we are using Password Based Share Access or User
  #
  my $smbConf = new Config::IniFiles( -file => nasCommon->smb_conf );
  unless ($smbConf) {
    $self->fatalError($config, 'f00020');
    return undef;
  }

  my $accessType = undef;

  if ($smbConf->val('global', 'security') eq 'user') {
    $accessType = 'user';
  } else {
    $accessType = 'pw';
  }

  # IMPORTANT !!!!!
  #
  # Access Type is to be HARDCODED to 'user' for the time being
  #
  $accessType = 'user';

	my $sharesInc = undef;
	$sharesInc = new Config::IniFiles( -file => nasCommon->shares_inc );
	unless ($sharesInc) {
		# Create a new shares.inc
		$sharesInc = new Config::IniFiles();
		unless ($sharesInc) {
			$self->fatalError($config, 'f00012');
			return undef;
		}
		$sharesInc->SetFileName(nasCommon->shares_inc);
	}

  my $shares = [];
  
  # local list of names, used to prevent duplicates in the returned list
  my %names;
  my $ct=0;
  foreach my $sect ($sharesInc->Sections()) {
    chomp $sect;
    $names{$sect} = 1;
    my @dpath = split('/',$sharesInc->val($sect,'path'));
    my $drive = $dpath[3];
###    if (!($sharesInc->val($sect,'available') eq "no")) {
    push @$shares, {  name  => $sect,        # Name of the share
                      id    => $ct++,        # A unique id
		      drive => $drive,
		      avail => $sharesInc->val($sect,'available'),
                      accessType =>          # Public or Private for Password based; n/a for user
                        ($accessType eq 'user' ? 'n/a' :
                            $sharesInc->val($sect, 'public') eq 'yes' ? 
                                  getMessage($config, 'm12006') :
                                  getMessage($config, 'm12007'))
                   };
###    }
  }
  
  return $shares;

}

1;
