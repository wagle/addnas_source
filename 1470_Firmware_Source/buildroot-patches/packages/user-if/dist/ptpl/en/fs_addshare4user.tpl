<p class="PageTitle">[% lang.m11013 %]</p>
<form action="/auth/fs_addshare.pl" method="post">
<br />
<table>
	<tr>
		<td>[% lang.m10005 %]:</td>
		<td><b>[% frm.sharename %]</b></td>
	</tr>
	<tr>
		<td>[% lang.m11019 %]:</td>
		<td><b>[% IF frm.cif == 'y' %][% lang.m11012 %][% END %]</b></td>
	</tr>
</table>
<br />
[% IF frm.cif == 'y' %]
<table border="0" width="90%">
<tr>
  <th align="left">[% lang.m11015 %]</th>
  <th width="50px" align="left">[% lang.m10006 %]</th>
  <th width="50px" align="left">[% lang.m10007 %]</th>
  <th width="50px" align="left">[% lang.m10008 %]</th>
</tr>
[% FOREACH user IN users %]
<tr>
  <td>[% user.name %]</td>
  <td><input type="radio" name="user_[% user.id %]_perm"  value="f"></td>
  <td><input type="radio" name="user_[% user.id %]_perm"  value="r"></td>
  <td><input type="radio" name="user_[% user.id %]_perm"  value="n" CHECKED></td>
</tr>
[% END %]
</table>
[% END %]
<br />
<br />
<input type="submit" name="submit" tabindex="1" value="[% lang.m11018 %]" >
<br />
<br />
<br />
<br />
<input type="button" name="back" tabindex="2" value="[% lang.m08021 %]"  onClick="location='/auth/fs_addshare.pl'">
<input type="button" name="cancel" tabindex="3" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<input type="hidden" name="nextstage" value="6">
<input type="hidden" name="sharename" value="[% frm.sharename %]" >
<input type="hidden" name="volume" value="[% frm.volume %]" >
<input type="hidden" name="cif" value="[% frm.cif %]" >
<input type="hidden" name="http" value="[% frm.http %]" >
<input type="hidden" name="nfs" value="[% frm.nfs %]" >
<input type="hidden" name="ftp" value="[% frm.ftp %]" >
</form>
