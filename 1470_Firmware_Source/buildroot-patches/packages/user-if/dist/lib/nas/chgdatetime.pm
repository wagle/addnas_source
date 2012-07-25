#
#	Change date and time of device
#
#	Ian Steel
#	September 2006
#
package nas::chgdatetime;

use Exporter;
@ISA=qw(nasCore);

use strict;

use DateTime;
use DateTime::TimeZone;
use Time::ZoneInfo;

use nasCommon;
use nas::setTimeZone;
use Service::DateText;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	if ($cgi->param('nextstage') == 1) {
		$self->stage1($cgi, $config);
		return;
	}

	unless (sudo("$nbin/chmod.sh 0644 " . nasCommon->zone_tab )) {
		$self->fatalError($config, 'f00020');
		return;
	}

	my $zones = Time::ZoneInfo->new( zonetab => nasCommon->zone_tab );
	my @timezones = sort ($zones->zones);

	my $tz;
	if ($cgi->param('timezonechange') == 1) {
        $tz = $cgi->param('new_timezone');
	} else {
        $tz = $config->val( 'general','timezone' ) || 'America/Boise';
    }
    my $dt = DateTime->now(time_zone => $tz);

    my $day = Service::DateText::getDay($config, $dt);
    my $month = Service::DateText::getMonth($config, $dt);
	my $vars = { 
		tabon => 'general',
		current_date => $day.' '.$dt->day_of_month.' '.$month.' '.$dt->year,
		current_time => $dt->hms().' '.$dt->time_zone_short_name,
		timezones => \@timezones,
		frm => {
			new_dd => $dt->day,
			new_mon => $dt->month,
			new_yyyy => $dt->year,
			new_hh => sprintf( '%02d',$dt->hour),
			new_min => sprintf( '%02d',$dt->minute),
			new_timezone => $tz,
		},
	};

	$self->outputTemplate('chgdatetime.tpl', $vars );
}

sub stage1($$$) {
	my ($self, $cgi, $config) = @_;

	my $zones = Time::ZoneInfo->new( zonetab => nasCommon->zone_tab );
	my @timezones = sort ($zones->zones);
	my $vars = { 
		tabon => 'general',
		timezones => \@timezones,
	};
	my $error = 0;

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
		my $tz = $new_timezone || $config->val( 'general','timezone' ) || 'America/Boise';
		my $dt = DateTime->from_epoch( epoch => time(), time_zone => $tz );
        my $day = Service::DateText::getDay($config, $dt);
        my $month = Service::DateText::getMonth($config, $dt);
		$vars->{current_date} = $day.' '.$dt->day_of_month.' '.$month.' '.$dt->year,
		$vars->{current_time} = $dt->hms(). ' '.$dt->time_zone_short_name;

		$self->outputTemplate('chgdatetime.tpl', $vars);
		return;
	}

	if ($new_timezone) {

    # work out offset from UTC
    #
#    my $tz = DateTime::TimeZone->new( name => $new_timezone );
#    my $dt = DateTime->now();
#    my $offset = $tz->offset_for_datetime($dt) / 3600;    # convert secs to hours too

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
      $self->fatalError($config, 'f00006');
      return;
    }
	}

	sudo("$nbin/updateHardwareClock.sh");

	$self->outputTemplate('chgdatetime1.tpl', { tabon => 'general' });

}

1;
