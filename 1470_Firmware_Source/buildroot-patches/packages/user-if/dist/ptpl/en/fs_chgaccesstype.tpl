<p class="PageTitle">[% lang.m09002 %]</p>
<form action="/auth/fs_chgaccesstype.pl" method="post">
<table border="0">
<tr>
	<td>[% lang.m09009 %]:</td>
	<td>[% current_level %]</td>
</tr>
<tr>
	<td>[% lang.m09010 %]:</td>
	<td>[% lang.m09007 %] <input type="radio" name="new_level" value="user" [% IF current_level_raw == 'user' %] CHECKED[% END %]>
  </td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>[% lang.m09008 %] <input type="radio" name="new_level" value="password" [% IF current_level_raw != 'user' %] CHECKED[% END %]>
  </td>
</tr>
</table>
<br />
<input type="submit" name="submit" tabindex="1" value="[% lang.m09011 %]" >
<input type="button" name="cancel" tabindex="2" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
[% IF current_level_raw == 'user' %]
<input type="button" name="userman"  value="[% lang.m09012 %]" onClick="location='/auth/fs_userman.pl'">
[% END %]
<input type="hidden" name="nextstage" value="1">
</form>
