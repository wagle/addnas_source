#
#	Change Network settings wizard
#
#	Ian Steel
#	September 2006
#
package nas::updnetwork;

use Exporter;
@ISA=qw(nasCore);

use strict;
use Errno qw(EAGAIN);

use nasCommon;
use IO::File;
use Config::Tiny;

sub main($$$) {

	my ($self, $cgi, $config) = @_;


	{
		if ($cgi->param('nextstage') == 1) {
			my $vars = getNetworkSettings();
			$vars->{tabon} = 'general';
			$self->outputTemplate('updnetwork1.tpl', $vars );
			last;
		}

		if ($cgi->param('nextstage') == 2) {
			$self->stage2($cgi, $config);
			last;
		}

		if ($cgi->param('nextstage') == 3) {
			$self->stage3($cgi, $config);
			last;
		}

		if ($cgi->param('nextstage') == 4) {
			$self->stage4($cgi, $config);
			last;
		}

		if ($cgi->param('nextstage') == 5) {
			$self->stage5($cgi, $config);
			last;
		}

		my $vars = { tabon => 'general' };
		$self->outputTemplate('updnetwork.tpl', $vars );

	}

}

sub getMask {

    my ($msk,$size) = @_;
    # Add a leading 1 to ensure there is a 'stopper' bit set.
    $msk += 2**$size;
    
    # divide by 2 until it goes odd
    my $cnt = $size;        
    while ( $msk && $cnt && !( $msk % 2) )
    {
        $msk  /= 2;
        $cnt -= 1;
    }
    
    # flip the div count to get the mask value.
    $cnt = $size - $cnt;

    # check that the remainder is a power of 2 less 1
    unless ( 2**($size - $cnt + 1) - 1 == $msk )
    {
        # negate if mask is invalid.
        $cnt = -1;
    }
    else
    {
	$cnt = $size-$cnt; 
    }
    
    # fix above algorithm which counts zeros in mask instead of ones
    return $cnt
}

sub dec2msk {
    
    my ( $decmsk ) = @_;
    
    my $msk = 2**32-2**(32-$decmsk);
    my @retarr;
    foreach my $index ( 1..4 )
    {
        my $mod = $msk % 2**8;
        unshift( @retarr, $mod );
        $msk -= $mod;
        $msk /= 2**8;
    }
    
    return @retarr;
}

sub getNetworkSettings {
	my $vars={};
	my $cfg=Config::Tiny->read( nasCommon->network_settings ) || Config::Tiny->new();
	my $ns={	# Lookups for fields to settings names
		ip => 'static_ip',
		msk => 'static_msk',
		gw => 'static_gw',
		dns1 => 'static_dns1',
		dns2 => 'static_dns2',
		dns3 => 'static_dns3',
		ntp => 'static_ntp',
	};
    
	foreach my $prefix ( qw( ip msk gw dns1 dns2 dns3 )) {
		my $tag=$ns->{$prefix}; 
		my $addr = $cfg->{_}->{$tag};
        
       my @addr;
       if ( $prefix eq 'msk' )
       {
           @addr = dec2msk( $cfg->{_}->{static_msk} );
       }
       else
       {
           @addr = split('\.',$addr);
       }
        
		foreach my $quad ( 1..4 ) {
			my $n=shift @addr;
			$vars->{frm}->{$prefix.$quad}=$n;
		}
	}
	if ($cfg->{_}->{network_mode} eq 'static') {
		 $vars->{frm}->{method}='m';
	} else {
		 $vars->{frm}->{method}='a';
	}
	
    $vars->{frm}->{ntp}=$cfg->{_}->{static_ntp};
	return $vars;
}


#
#	Ensure username and password are fit for purpose
#
sub stage2($$$) {

	my ($self, $cgi, $config) = @_;

	my $error = 0;


  # User has chosen Manual so show them a page to set up the details.
  #
#  my $ifconfig = `ifconfig eth0`;
#  $ifconfig =~ /^\s*inet addr:(\d+)\.(\d+)\.(\d+)\.(\d+).*Mask:(\d+)\.(\d+)\.(\d+)\.(\d+)/m;
#  $vars->{frm}->{ip1} = $1;
#  $vars->{frm}->{ip2} = $2;
#  $vars->{frm}->{ip3} = $3;
#  $vars->{frm}->{ip4} = $4;
#  $vars->{frm}->{sn1} = $5;
#  $vars->{frm}->{sn2} = $6;
#  $vars->{frm}->{sn3} = $7;
#  $vars->{frm}->{sn4} = $8;

	# If the user has chosen dhcp (automatic) note this fact and go straight to the 'finish' page.
	#
	my $mode = $cgi->param('method');
	if ($mode eq 'a') {   # dhcp (automatic)
		my $vars={};
		$vars->{frm}->{method} = 'a';
		$self->outputTemplate('updnetwork4.tpl', $vars);
		return;
	} else {
		my $vars=getNetworkSettings();
		$vars->{tabon} = 'general';
		$vars->{frm}->{method} = 'm';
		$self->outputTemplate('updnetwork2.tpl', $vars);
	}

}

sub stage3($$$) {

	my ($self, $cgi, $config) = @_;

  # Determine the current gateway ip
  #
#  my $route = `ip route show`;
#  $route =~ /^default via (\d+)\.(\d+)\.(\d+)\.(\d+)/m;
#  $vars->{frm}->{gw1} = $1;
#  $vars->{frm}->{gw2} = $2;
#  $vars->{frm}->{gw3} = $3;
#  $vars->{frm}->{gw4} = $4;

	my $vars=getNetworkSettings();
	$vars->{tabon} = 'general';

    copyFormVars($cgi, $vars);
        
    if ( my $ecode = nasCommon::getIpError( $vars, "ip", 0 ) )
    { 
         $vars->{err}->{ip} = getMessage($config, $ecode);
         $self->outputTemplate('updnetwork2.tpl', $vars);
         return;
    }
    
    my @ip;
    my $msk = 0;
    foreach my $quad ( 1..4 )
    {
        $ip[$quad-1]  = $cgi->param('ip'.$quad);
        my $tmp       = $cgi->param('msk'.$quad);
        
        if ( my $ecode = nasCommon::getOctError($tmp ) )
        {
            nasCommon::setErrorMessage( $vars, $config, 'msk', $ecode );
            $vars->{focusOn} = 'msk'.$quad;
            $self->outputTemplate('updnetwork2.tpl', $vars);
            return;
        }
        
        $msk *= 2**8;
        $msk += $tmp;
    }
    
    my $netMask = getMask( $msk, 32 );
    

    if ( $netMask <= 0 )
    {
         nasCommon::setErrorMessage( $vars, $config, 'msk', 'e08008' );
         $vars->{frm}->{msk1} = "xxx";
         $vars->{frm}->{msk2} = "xxx";
         $vars->{frm}->{msk3} = "xxx";
         $vars->{frm}->{msk4} = "xxx";
         $vars->{focusOn} = 'msk1';
         $self->outputTemplate('updnetwork2.tpl', $vars);
         return;
    }
            
	$vars->{frm}->{method}=$cgi->param('method');
    $vars->{frm}->{ip} =  $ip[0].'.'.$ip[1].'.'.$ip[2].'.'.$ip[3];

	$vars->{frm}->{msk} = $cgi->param('msk1').'.'.$cgi->param('msk2').'.'.$cgi->param('msk3').'.'.$cgi->param('msk4');
	$vars->{frm}->{sn} = $netMask;
	$self->outputTemplate('updnetwork3.tpl', $vars);

}

sub stage4($$$) {

	my ($self, $cgi, $config) = @_;
	my $vars = { tabon => 'general' };
	my $ecode = 0;

    copyFormVars($cgi, $vars);

    # General IP address checks
    foreach my $prefix ( "gw", "dns1", "dns2", "dns3" )
    {
        if ( my $tmpecode = nasCommon::getIpError( $vars, $prefix, 1 ) )
        {
             $ecode = $tmpecode;
             $vars->{err}->{$prefix} = getMessage($config, $ecode);
        }
    }

    unless ( $ecode ) {
        # Additional gateway address checks
        if ( $ecode = nasCommon::getGwError( $vars ) )
        {
            $vars->{err}->{"gw"} = getMessage($config, $ecode);
        }
    }

    my $ntp  = $cgi->param('ntp');
    if ( $ntp && !( $ntp =~ /^[a-zA-Z0-9\._-]*$/ ) )
    {
        $ecode = 'e08005';
        nasCommon::setErrorMessage( $vars, $config, 'ntp', $ecode );
        $vars->{frm}->{ntp} = "";
    }
    
    if ( $ecode )
    {
        $self->outputTemplate('updnetwork3.tpl', $vars);
        return;
    }
    
    
   copyFormVars($cgi, $vars);

	$vars->{frm}->{ntp}=$cgi->param('ntp');
	$vars->{frm}->{method}=$cgi->param('method');
	#$vars->{frm}->{gw} = $cgi->param('gw1') . '.' . $cgi->param('gw2') . '.' .
	#	$cgi->param('gw3') . '.' . $cgi->param('gw4');
   
	# Extract the dns and ntp addresses into vars

    $vars->{frm}->{warning} = 0;
	foreach my $prefix ( qw( gw dns1 dns2 dns3 )) {
		my @ip;
		foreach my $quad ( 1..4 ) {
			my $value = $cgi->param( $prefix.$quad );
			push @ip,$value if ($value=~/^\d+$/);
		}
		$vars->{frm}->{$prefix}=join('.',@ip) if @ip;
        
       if ( $cgi->param( $prefix.'4' ) == 255 )
       {
           # set warning if ip address maybe brodcast
           $vars->{frm}->{warning} = 1;
       }
	}
    
	$self->outputTemplate('updnetwork4.tpl', $vars);

}

sub stage5($$$) {

	my ($self, $cgi, $config) = @_;

	my $vars = { tabon => 'general' };
	my $error = 0;

	my $method = $cgi->param('method');
	$method ||= 'a';

	my $ip = $cgi->param('ip');
	my $sn = $cgi->param('sn');
	my $gw = $cgi->param('gw');
	my $ntp = $cgi->param('ntp');
	my $dns1 = $cgi->param('dns1');
	my $dns2 = $cgi->param('dns2');
	my $dns3 = $cgi->param('dns3');

	# Write network-settings - Either read existing file or create new one
	my $cfg=Config::Tiny->read( nasCommon->network_settings ) || Config::Tiny->new();
	# Create settings in the root '_' section
	if ($method eq 'm') {
		$cfg->{_}->{network_mode} = "static";
		$cfg->{_}->{static_ip} = $ip;
		$cfg->{_}->{static_gw} = $gw;
		$cfg->{_}->{static_msk} =$sn;
		$cfg->{_}->{static_ntp} = $ntp;
		$cfg->{_}->{static_dns1} = $dns1;
		$cfg->{_}->{static_dns2} = $dns2;
		$cfg->{_}->{static_dns3} = $dns3;
	} else {
		$cfg->{_}->{network_mode} = "dhcp";
	}
	$cfg->write( nasCommon->network_settings );

#	unless (sudo("$nbin/updNetwork.sh $method $ip $sn $gw $ntp $dns1 $dns2 $dns3")) {
#	$self->outputTemplate('updnetwork5.tpl', $vars);

	# Remove the network started lock file
	unless (sudo("$nbin/remove.sh /var/run/network_started")) {
		$self->fatalError($config, 'f00010');
		return;
	}

	FORK: {
		if (my $pid = fork) {
			# Parent here, just return normally
		} elsif (defined $pid) {
			# Child here - sleep awhile
			sleep 2;

			# Invoke script to restart networking
			system('sudo '.nasCommon->nas_nbin."quickRestartNetwork.sh");

			# Make child die as it has finished its work
			exit 0;
		} elsif ($! == EAGAIN) {
			sleep 5;
			redo FORK;
		} else {
			die "Can't fork: $!\n";
		}
	}

	# Remove the network_started lock file here
	print $cgi->redirect('/hold.pl');
}

1;
