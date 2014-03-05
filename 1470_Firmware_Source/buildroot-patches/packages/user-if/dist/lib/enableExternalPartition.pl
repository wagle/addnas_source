#!/usr/bin/env perl
#!/usr/bin/perl
#
# Copyright (C) 2007 PLX Technology Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# This will use the methods of the WEB-UI to remove all external shares. It is
# intended that this program be run once before lighttpd and the Web-UI have
# started.
#
use strict;

use Service::Shares;

my $uuid = $ARGV[0];
Service::Shares->enableExternalPartition($uuid);

