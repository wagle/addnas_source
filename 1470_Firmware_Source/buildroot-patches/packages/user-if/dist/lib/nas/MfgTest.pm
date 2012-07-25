
package nas::MfgTest;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon ;
use Switch;
use SysCmd;
use IO::File;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

    # get page parameters
    my $led = $cgi->param('led');
    
    # apply led param if in range
    if ( ( $led >= 0) && ($led <= 63)) {
        system( 'sudo /bin/sh -c "/bin/echo -n '.$led.' >/sys/class/leds/oxnas-leds\:capacity/brightness"' );
    }
    
    # get disk info and filter for serial numbers
    open( CommandOutput, 'sudo /sbin/hdparm -I /dev/sda /dev/sdb | grep "Serial Number" |');
    my @DiskSerialNumbers = <CommandOutput>;
    close( CommandOutput );
    
    # display params and disk serial nos
    $self->outputTemplate('mfgtest.tpl', 
        {
            tabon => 'home',
            LedSetting => $led,
            SerialNos => \@DiskSerialNumbers
        } );

}

1;
