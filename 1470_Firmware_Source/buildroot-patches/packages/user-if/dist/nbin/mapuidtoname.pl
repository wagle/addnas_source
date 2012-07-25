#!/usr/bin/env perl
#
# Prints the username for the given userid
#
# Ian Steel
# October 2006
#
use strict;

# bruce - This should use PERL5LIB now...
#use lib '/var/www/nas';

use nasCommon;
print mapUidToName()->{$ARGV[0]} . "\n";

