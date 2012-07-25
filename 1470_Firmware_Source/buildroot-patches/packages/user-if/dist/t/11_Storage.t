# Test for Storage.pm

use Test::More qw(no_plan);
use Data::Dumper;

use_ok( 'Service::Storage' );

my $s = new Service::Storage( '/' );

ok( $s,			'Instantiated Service::Storage( / )' );
ok( $s->collect(),	'collect()' );	
ok( $s->total(),	'total() = '.$s->total() );
ok( $s->used(),		'used() = '.$s->used() );
ok( $s->available(),	'available() = '.$s->available() );
ok( $s->pc_used(),	'pc_used() = '.$s->pc_used() );
ok( $s->pc_free(),	'pc_free() = '.$s->pc_free() );

ok( $s->data_volume(),	'data_volume() = '.$s->data_volume() );
#ok( $s->drive_type(),	'drive_type() = '.$s->drive_type() );
#ok( $s->external_volumes(),	'external_volumes() = '.Dumper( $s->external_volumes()) );
#ok( $s->all_devices(),	'all_devices() = '.Dumper( $s->all_devices()) );
#ok( $s->all_disks(),	'all_disks() = '.Dumper( $s->all_disks()) );
