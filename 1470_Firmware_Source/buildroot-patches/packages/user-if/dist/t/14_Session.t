# Test for Session::NAS

use Data::Dumper;
use Test::More qw(no_plan);

use_ok( 'Session::NAS' );
my $s = new Session::NAS( 'test_cookie','+2m' );
ok( $s,				q[new Session::NAS( 'test_cookie','+2m' )] );
ok( $s->liveSessions(),		'liveSessions: '.Dumper( $s->liveSessions()) );
ok( $s->cookie(),		'cookie: '.$s->cookie() );
