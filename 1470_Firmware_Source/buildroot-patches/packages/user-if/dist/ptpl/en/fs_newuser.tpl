
<p class="PageTitle">[% lang.m10001 %]</p>
<form action="/auth/fs_newuser.pl" method="post">
<table>
	<tr>
		<td>[% lang.m10002 %]:</td>
		<td><input type="text" name="new_username" id="new_username" tabindex="1" size="20" maxlength="20" value="[% frm.new_username %]"><span class="valerror">[% err.new_username %]</span></td>
	</tr>
	<tr>
		<td>[% lang.m04002 %]:</td>
		<td><input type="password" name="pword1" id="pword1" tabindex="2" size="20" maxlength="21"><span class="valerror">[% err.pword1 %]</span></td>
	</tr>
	<tr>
		<td>[% lang.m04003 %]:</td>
		<td><input type="password" name="pword2" id="pword2" tabindex="3" size="20" maxlength="21"><span class="valerror">[% err.pword2 %]</span></td>
	</tr>
</table>
<br />
<br />
[% lang.m10004 %]
<br />
<table border="0" width="100%">
<tr>
  <th align="left">[% lang.m10005 %]</th>
  <th width="50px" align="left">[% lang.m10006 %]</th>
  <th width="50px" align="left">[% lang.m10007 %]</th>
  <th width="50px" align="left">[% lang.m10008 %]</th>
</tr>
[% FOREACH sh IN shares %]
<tr>
  <td>[% sh.name %]</td>
  <td><input type="radio" name="sh_[% sh.id %]_perms"  value="f"></td>
  <td><input type="radio" name="sh_[% sh.id %]_perms"  value="r"></td>
  <td><input type="radio" name="sh_[% sh.id %]_perms"  value="n" CHECKED>
      <input type="hidden" name="sh_[% sh.id %]_name"  value="[% sh.name %]">
  </td>
</tr>
[% END %]
</table>
<br />
<br />
<input type="submit" name="submit" value="[% lang.m10001 %]" tabindex="4" >
<input type="hidden" name="nextstage" value="1" >
<input type="button" name="cancel" value="[% lang.m01027 %]" tabindex="5"  onClick="location='/auth/fs_userman.pl'">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "new_username" [% END %] ).focus();
</script>

</form>
