# Test for SysCmd.pm

use Test::More qw(no_plan);

use_ok( 'SysCmd' );

ok( SysCmd->ifconfig, 	'SysCmd->ifconfig is '.SysCmd->ifconfig );
ok( SysCmd->netstat, 	'SysCmd->netstat is '.SysCmd->netstat );

