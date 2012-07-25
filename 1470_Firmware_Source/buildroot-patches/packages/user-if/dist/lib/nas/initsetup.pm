#
#	Initial setup wizard
#
#	Ian Steel
#	September 2006
#
package nas::initsetup;

use Exporter;
@ISA=qw(nasCore);

use strict;

use DateTime;
use DateTime::TimeZone;
use Time::ZoneInfo;
use nas::setTimeZone;

use nasCommon;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	{
		my $vars = {tabon => 'home'};
		if ($cgi->param('nextstage') == 1) {
			$self->outputTemplate('initsetup1.tpl', $vars );
			return;
		}

		if ($cgi->param('nextstage') == 2) {
			$vars->{frm}->{username} = 'admin';
			$self->outputTemplate('initsetup2.tpl', $vars);
			return;
		}

		if ($cgi->param('nextstage') == 3) {
			$self->stage3($cgi, $config);
			return;
		}

		if ($cgi->param('nextstage') == 4) {
			$self->stage4($cgi, $config);
			return;
		}

		# default
		#
		$self->outputTemplate('initsetup.tpl', $vars );
	}

}

#
#	Ensure username and password are fit for purpose
#
sub stage3($$$) {

	my ($self, $cgi, $config) = @_;

	my $vars={ tabon => 'home' };
	my $error = 0;

    # don't do the username processing if we are re-drawing the page after a 
    # timezone change
	if (!($cgi->param('timezonechange') == 1)) {
        my $username = $cgi->param('username');
        my $pword1 = $cgi->param('pword1');
        my $pword2 = $cgi->param('pword2');
    
        my $ecode = nasCommon::getUsernameError( $username );
        if ( $ecode )
        {
            nasCommon::setErrorMessage( $vars, $config, 'username', $ecode );
            $error = 1;
        }
                
        $ecode = nasCommon::getPasswordError( $pword1, $pword2 );
        if ( $ecode )
        {
            nasCommon::setErrorMessage( $vars, $config, 'pword1', $ecode );
            $error = 1;
        }
            
        if ($error) {
            $self->outputTemplate('initsetup2.tpl', $vars );
            return;
        }
    }
    
	# Insert the date & time
    my $zones = Time::ZoneInfo->new( zonetab => nasCommon->zone_tab );
    my @timezones = sort ($zones->zones);

    # If the timezone has changed, use the new timezone, otherwise default to 
	my $tz;
    my $password;
	if ($cgi->param('timezonechange') == 1) {
        $tz = $cgi->param('new_timezone');
        $password = $cgi->param('pword'),
	} else {
        $tz = $config->val( 'general','timezone' ) || 'America/Boise';
        $password = $cgi->param('pword1'),
    }
    my $dt = my $dt = DateTime->now(time_zone => $tz);
    my $day = Service::DateText::getDay($config, $dt);
    my $month = Service::DateText::getMonth($config, $dt);

    $vars->{current_date} = $day.' '.$dt->day.' '.$month.' '.$dt->year;
    $vars->{current_time} = $dt->hms(). ' '.$dt->time_zone_short_name;
    $vars->{timezones} = \@timezones;
    $vars->{frm} = {
        username => $cgi->param('username'),
        pword => $password,
        new_dd => $dt->day,
        new_mon => $dt->month,
        new_yyyy => $dt->year,
        new_hh => sprintf( '%02d',$dt->hour),
        new_min => sprintf( '%02d',$dt->minute),
        new_timezone => $tz
    };

	$self->outputTemplate('initsetup3.tpl', $vars);
}

#
#	Ensure optional date & time are fit for purpose. If all is well, apply changes to system.
#
sub stage4($$$) {

	my ($self, $cgi, $config) = @_;

	my $vars = { tabon => 'home' };
	my $error = 0;

	my $username = $cgi->param('username');
	my $pword = $cgi->param('pword');

	# Validate date & time provided
	#
	my $new_dd = $cgi->param('new_dd');
	my $new_mon = $cgi->param('new_mon');
	my $new_yyyy = $cgi->param('new_yyyy');

	my $new_hh = 0+$cgi->param('new_hh');
	my $new_min = 0+$cgi->param('new_min');

	my $new_timezone = $cgi->param('new_timezone');

        # Validate date and time
        eval( "DateTime->new( year => $new_yyyy, month => $new_mon, day => $new_dd);" ) || do {
                # Post an error
                nasCommon::setErrorMessage( $vars, $config, 'date', 'e05001' );
                $error = 1;
        };

        eval( "DateTime->new ( year => $new_yyyy, hour => $new_hh, minute => $new_min);" )|| do {
                # Post an error
print STDERR "DateTime: error for $new_yyyy $new_hh $new_min\n";
                nasCommon::setErrorMessage( $vars, $config, 'time', 'e05002' );
                $error = 1;
        };

	if ($new_dd || $new_mon || $new_yyyy) {
		if ((!$new_dd) || (!$new_mon) || (!$new_yyyy)) {
			nasCommon::setErrorMessage( $vars, $config, 'date', 'e05001' );
			$error = 1;
		}
	}

	if ($new_hh || $new_min) {
		if ((!defined($new_hh)) || (!defined($new_min))) {
			nasCommon::setErrorMessage( $vars, $config, 'time', 'e05002' );
			$error = 1;
		}
	}

	if ($error) {
		copyFormVars($cgi, $vars);

	        my $tz = $config->val( 'general','timezone' ) || 'America/Boise';
        	my $dt = DateTime->from_epoch( epoch => time(), time_zone => $tz );
        	my $day = Service::DateText::getDay($config, $dt);
        	my $month = Service::DateText::getMonth($config, $dt);

		$vars->{current_date} = $day.' '.$dt->day.' '.$month.' '.$dt->year;
		$vars->{current_time} = $dt->hms(). ' '.$dt->time_zone_short_name;

    my $zones = Time::ZoneInfo->new();
    my @timezones = sort ($zones->zones);
    $vars->{timezones} = \@timezones;

		$self->outputTemplate('initsetup3.tpl', $vars);
		return;
	}


	# We MUST output the template before we change the server as the server needs to be restarted.
	#
	$|=1;	# immediate flushing of output pipe

	if ($new_timezone) {
    unless (sudo("$nbin/chmod.sh 0666 " . nasCommon->TZ )) {
      $self->fatalError($config, 'f00020');
      return;
    }

    nas::setTimeZone::updateTZ($new_timezone);

	  $config->newval('general', 'timezone', $new_timezone);
	  unless ($config->RewriteConfig) {
      $self->fatalError($config, 'f00003');
      return;
    }

	}

	if ($new_dd) {
		$new_dd = sprintf('%02d', $new_dd);
		$new_mon = sprintf('%02d', $new_mon);

		unless (sudo("$nbin/setDeviceDate.sh '$new_dd' '$new_mon' $new_yyyy")) {
      $self->fatalError($config, 'f00006');
      return;
    }
	}

        if (defined( $new_hh) || defined( $new_min )) {
		$new_hh = sprintf('%02d', $new_hh);
		$new_min = sprintf('%02d', $new_min);

		unless (sudo("$nbin/setDeviceTime.sh '$new_hh' '$new_min'")) {
      $self->fatalError($config, 'f00007');
      return;
    }
	}

	$config->newval('general', 'initial_config_done', 'y');
	unless ($config->RewriteConfig) {
    $self->fatalError($config, 'f00003');
    return;
  }

	my $tz = $config->val( 'general','timezone' ) || 'America/Boise';
	my $dt = DateTime->from_epoch( epoch => time(), time_zone => $tz );
	my $day = Service::DateText::getDay($config, $dt);
	my $month = Service::DateText::getMonth($config, $dt);
	my $date_string = $day.' '.$dt->day.' '.$month.' '.$dt->year;

	$self->outputTemplate('initsetup4.tpl', {
                tabon => 'home',
                frm => {
			username => $username,
			pword => $pword,
                        new_dd => $new_dd,
                        new_mon => $new_mon,
                        new_yyyy => $new_yyyy,
                        new_hh => $new_hh,
                        new_min => $new_min,
                        new_timezone => $new_timezone,
			date_string => $date_string,
                },});

	sleep(2);	# Allow time for page to render before applying the changes and restarting 
				#	the web server

	unless (sudo("$nbin/setAdminUser.sh '$username' '$pword'")) {
      $self->fatalError($config, 'f00009');
      return;
  }

	sudo("$nbin/updateHardwareClock.sh");
}

1;
