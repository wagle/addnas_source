#!/usr/bin/perl
#
# Prints the username for the given userid
#
# Ian Steel
# October 2006
#
use strict;

# bruce - This should use PERL5LIB
#use lib '/var/www/nas';

use nasCommon;
print mapNameToUid()->{$ARGV[0]} . "\n";

