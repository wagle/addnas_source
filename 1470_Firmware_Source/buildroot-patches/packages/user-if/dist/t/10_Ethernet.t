# Test for Ethernet.pm

use Test::More qw(no_plan);

use_ok( 'Service::Ethernet' );

my $eth = new Service::Ethernet( 'eth0' );
ok( $eth,			'Instantiated Service::Ethernet(eth0)' );
ok( $eth->collect(),		'collect()' );	
ok( $eth->address(),		"address() = ".$eth->address() );
ok( $eth->status(),		"status() = ".$eth->status() );
#ok( $eth->speed(),		"speed() = ".$eth->speed() );
ok( $eth->gw(),			"gw() = ".$eth->gw() );

