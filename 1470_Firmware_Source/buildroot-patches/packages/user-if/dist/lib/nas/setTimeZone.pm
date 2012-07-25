package nas::setTimeZone;

#
# given a timezone of the format "Europe/London" for example, creates the /etc/TZ file to cater for daylight
# saving switches automatically.
#

use strict;

use DateTime;
use DateTime::TimeZone;

use constant UTC_START => 0;
use constant UTC_END => 1;
use constant LOCAL_START => 2;
use constant LOCAL_END => 3;
use constant OFFSET => 4;
use constant IS_DST => 5;
use constant SHORT_NAME => 6;

sub updateTZ($) {
	my ($zoneName) = @_;

	unless ($zoneName) {
		warn "\n\n\tusage: nas::setTimeZone::updateTZ timezone\n\n\t\teg updateTZ America/Boise\n\n";
	}

	# Create a date object for the epoch (Jan 1 1970). From this we can get the rata die seconds which we will
	# use to subtract from the LOCAL_START & LOCAL_END seconds.
	#
	my $epochDt = DateTime->new ( year => 1970, month => 1, day => 1 );
	my $tz = DateTime::TimeZone->new( name => $zoneName );
	my $dt = DateTime->now();
	my $span = $tz->_span_for_datetime( 'utc', $dt );

	my $nextSpan;
	my $nextStartDt;
	my $nextEndDt;

	if ($span->[1] != "inf") {
		# Now get details for the following DST period.
		#
		$nextSpan = $tz->_spans_binary_search('utc', $span->[1]);

		# Create a DateTime object for each DST switching date. From this we can get the Julian day number
		#
		$nextStartDt = DateTime->from_epoch( epoch => $nextSpan->[LOCAL_START] - $epochDt->local_rd_as_seconds() );
		$nextEndDt = DateTime->from_epoch( epoch => $nextSpan->[LOCAL_END] - $epochDt->local_rd_as_seconds() );
	}

	# Update the /etc/TZ file
	#
	if (open (TZ, ">".nasCommon->TZ)) {
		my $hm = $span->[OFFSET]/-3600;
		if ($hm ne (int $hm)) {
			$hm > 0 and $hm = (int $hm) . ':' . (int (($hm - int $hm) * 60)) ;
			$hm < 0 and $hm = (int $hm) . ':' . (int (((int $hm) - $hm) * 60))
		}

		if (($span->[1] != "inf") && ($nextStartDt->doy() != $nextEndDt->doy())) {
			print TZ $span->[SHORT_NAME] . $hm . $nextSpan->[SHORT_NAME] .
			',J' . $nextStartDt->doy() . ',J' . $nextEndDt->doy() . "\n" ;
		} else{
			print TZ $span->[SHORT_NAME] . $hm . "\n" ;
		}

		close(TZ);
	} else {
		warn "Failed to open ".nasCommon->TZ." (w)";
	}
}

1;
