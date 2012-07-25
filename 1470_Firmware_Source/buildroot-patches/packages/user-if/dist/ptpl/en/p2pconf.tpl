<p class="PageTitle">[% lang.m09021 %]</p>
[% frm.mlconfigstatus %]<BR>
[% frm.mlconfigstatus2 %]<BR>
[% IF frm.showdriveselector %]
	<form action="/auth/p2pconf.pl" method="post">
	<input type="hidden" name="dofunc" value="setdrive">
	<select name="volume" size="1">
	[% FOREACH ex IN extvols %]
	<option value="[% ex.path %]">[% ex.prefix %] [% ex.path %]</option>
	[% END %]
	</select>	
	<input type="submit" name="submit" value="Save">
[% END %]
	<form action="/auth/p2pconf.pl" method="post">
	<input type="hidden" name="dofunc" value="RESETPW">
	<input type="submit" name="submit" value="Delete Passwords"></form>
[% IF frm.mlrunning %]
	<font color=green>[% lang.mld001 %]</font><BR><form action="/auth/p2pconf.pl" method="post"><input type="hidden" name="dofunc" value="STOP"><input type="submit" name="submit" value="[% lang.mld005 %]"></form><form action="/auth/p2pconf.pl" method="post">	<input type="hidden" name="dofunc" value="RESTART"><input type="submit" name="submit" value="[% lang.mld006 %]"></form><a href="http://[% fr_net_ip_addr %]:4080/" target="MLDCONTROL">[% lang.mld003 %]</a>
[% ELSE %]
	<font color=red>[% lang.mld002 %]</font><BR>
	<form action="/auth/p2pconf.pl" method="post">
	<input type="hidden" name="dofunc" value="START">
	<input type="submit" name="submit" value="[% lang.mld004 %]"></form>
[% END %]
