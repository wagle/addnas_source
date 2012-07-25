# Test that Core modules compile with use_ok

use Test::More qw(no_plan);

use_ok( 'nasCommon' );
use_ok( 'nasCore' );
use_ok( 'SysCmd' );
use_ok( 'Service::Storage' );
use_ok( 'Service::Ethernet' );
use_ok( 'Permission' );
use_ok( 'Service::Shares' );
use_ok( 'Session::NAS' );

# Use each module under lib/nas
foreach my $module ( split(/\s+/, `ls lib/nas/*.pm`)) {
	($module=~/([^\/\.]+).pm/) && use_ok( "nas::".$1 );
}



is( system("perl -I./lib -c ./lib/nasMaster.pl" ), 0, 'nasMaster.pl compile' );
