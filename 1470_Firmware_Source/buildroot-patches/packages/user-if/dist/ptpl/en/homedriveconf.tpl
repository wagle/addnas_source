<p class="PageTitle">Home directory drive.</p>
[% frm.hdconfigstatus %]<BR>
[% frm.hdconfigstatus2 %]<BR>
[% IF frm.showdriveselector %]
	<form action="/auth/homedriveconf.pl" method="post">
	<input type="hidden" name="dofunc" value="setdrive">
	<select name="volume" size="1">
	[% FOREACH ex IN extvols %]
	<option value="[% ex.path %]">[% ex.prefix %] [% ex.path %]</option>
	[% END %]
	</select>	
	<input type="submit" name="submit" value="Save">
[% END %]
