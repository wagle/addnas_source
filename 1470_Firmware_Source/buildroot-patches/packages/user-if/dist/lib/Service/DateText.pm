#!/usr/bin/env perl
# Class   : Service::DateText.pm
# Purpose : Translating between human/computer language dates 
# Author  : R crewe
#

use strict;
use nasCommon;
use DateTime;
use Switch;

# This object is the Status returned as a result of examining the RAID 
# status on all the RAID drives.
package Service::DateText;

    sub new {
        my $class = shift;
        my $this = {};
        bless $this, $class;
        
        return $this;
    };

    # Get the text for the day af week
    sub getDay {
        my $config = shift;
        my $date = shift;

        my $day;
        switch ($date->day_of_week) {
            case (1 ){ $day = nasCommon::getMessage($config, 'm05025');}
            case (2 ){ $day = nasCommon::getMessage($config, 'm05026');}
            case (3 ){ $day = nasCommon::getMessage($config, 'm05027');}
            case (4 ){ $day = nasCommon::getMessage($config, 'm05028');}
            case (5 ){ $day = nasCommon::getMessage($config, 'm05029');}
            case (6 ){ $day = nasCommon::getMessage($config, 'm05030');}
            case (7 ){ $day = nasCommon::getMessage($config, 'm05031');}
        }
        
        return $day;
    };
    
    # Get the text for the month
    sub getMonth {
        my $config = shift;
        my $date = shift;

        my $month;
        switch ($date->month) {
            case (1 ){ $month = nasCommon::getMessage($config, 'm05006');}
            case (2 ){ $month = nasCommon::getMessage($config, 'm05007');}
            case (3 ){ $month = nasCommon::getMessage($config, 'm05008');}
            case (4 ){ $month = nasCommon::getMessage($config, 'm05009');}
            case (5 ){ $month = nasCommon::getMessage($config, 'm05010');}
            case (6 ){ $month = nasCommon::getMessage($config, 'm05011');}
            case (7 ){ $month = nasCommon::getMessage($config, 'm05012');}
            case (8 ){ $month = nasCommon::getMessage($config, 'm05013');}
            case (9 ){ $month = nasCommon::getMessage($config, 'm05014');}
            case (10){ $month = nasCommon::getMessage($config, 'm05015');}
            case (11){ $month = nasCommon::getMessage($config, 'm05016');}
            case (12){ $month = nasCommon::getMessage($config, 'm05017');}
        }

        return $month;
    };
1;
