# Test for Config::Tiny
# Make sure that this module will cope with an ini file with no section.
# The settings with no section appear under the 'root' section called '_'.

use Test::More qw(no_plan);
use IO::File;

use_ok( 'Config::Tiny' );

my $file = '/tmp/config_test';

# Write a test file
my $fd=new IO::File( ">".$file );
print( $fd "name = bruce\n" );
print( $fd "email=bruce.james\@oxsemi.com\n" );
print( $fd "addr=192.168.1.100\n" );
$fd->close();

# Create a config
my $cfg = Config::Tiny->new();
ok( $cfg,		'Instantiated Config::Tiny' );

# Test basic read
$cfg = Config::Tiny->read( $file );
is( $cfg->{_}->{name},		'bruce',			q[$cfg{_}->{name} = 'bruce'] );
is( $cfg->{_}->{email},		'bruce.james@oxsemi.com',	q[$cfg{_}->{email} = 'bruce.james@oxsemi.com'] );
is( $cfg->{_}->{addr},		'192.168.1.100',		q[$cfg{_}->{addr} = '192.168.1.100'] );

# Test value change & write
$cfg->{_}->{addr} = '10.0.0.2';
$cfg->{_}->{ntp} = '10.0.0.252';
is( $cfg->{_}->{addr},		'10.0.0.2',		q[$cfg{_}->{addr} = '10.0.0.2'] );
is( $cfg->{_}->{ntp},		'10.0.0.252',		q[$cfg{_}->{ntp} = '10.0.0.252'] );
$cfg->write( $file );

undef $cfg;	# Just to make sure

# Create a config
my $cfg = Config::Tiny->new();
ok( $cfg,		'Instantiated Config::Tiny' );

# Test basic read
$cfg = Config::Tiny->read( $file );
is( $cfg->{_}->{ntp},		'10.0.0.252',			q[$cfg{_}->{ntp} = '10.0.0.252'] );

# Try read & write of a non existing config
undef $cfg;	# Just to make sure
unlink( $file );

# Create a config
my $cfg = Config::Tiny->new();
ok( $cfg,		'Instantiated Config::Tiny' );

is( Config::Tiny->read( $file ),	undef,	'read is undef');

$cfg->{_}->{ntp} = '10.0.0.252';
ok( $cfg->write( $file ),	'write' );
