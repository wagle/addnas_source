# Test for Permission.pm

use Test::More qw(no_plan);

use_ok( 'Permission' );

my $file = '/tmp/permission_test';
unlink( $file );
my $dir = '/tmp/permission_test_dir/';
rmdir( $dir );

my $s = new Permission( '/tmp/permission_test','0644','james','engineer' );
ok( $s,					'Instantiated Permission()' );
is_deeply( [$s->check()],['NOTEXIST'],	'check()');
ok( $s->fix(),				'fix()' );
is_deeply( [$s->ensure()],[],		'ensure()');

my $s = new Permission( '/tmp/permission_test_dir/','0755','james','engineer' );
ok( $s,					'Instantiated Permission()' );
is_deeply( [$s->check()],['NOTEXIST'],	'check()');
ok( $s->fix(),				'fix()' );
is_deeply( [$s->ensure()],[],		'ensure()');
