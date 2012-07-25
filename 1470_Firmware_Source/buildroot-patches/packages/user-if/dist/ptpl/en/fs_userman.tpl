<p class="PageTitle">[% lang.m09012 %]</p>
[% lang.m09014 %]:
<table border="0">
[% FOREACH user IN users %]
<tr>
	<td>[% user.name %]</td>
  <td><a href="/auth/fs_deluser.pl?uid=[% user.uid %]">[% lang.m09015 %]</a></td>
</tr>
[% END %]
</table>
<br />
<br />
<form action="/auth/fs_userman.pl" method="post">
[% IF users.size() > 0 %]
[% lang.m04008 %]
<br/>
<select name="uid" size="1">
[% FOREACH user IN users %]
<option value="[% user.uid %]">[% user.name %]</option>
[% END %]
</select>
<br />
<table>
    <tr>
        <td>[% lang.m04002 %] </td>
        <td><input type="password" name="pword1" id="pword1" tabindex="1" size="20" maxlength="21"><span class="valerror">[% err.pword1 %]</span></td>
    </tr>
    <tr>
        <td>[% lang.m04003 %] </td>
        <td><input type="password" name="pword2" id="pword2" tabindex="2" size="20" maxlength="21"><span class="valerror">[% err.pword2 %]</span></td>
    </tr>
</table>
<br />
<input type="submit" name="submit" tabindex="3" value="[% lang.m09016 %]" >
<input type="hidden" name="nextstage" value="1" >
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "pword1" [% END %] ).focus();
</script>
[% END %]
<input type="button" name="create" tabindex="4" value="[% lang.m09017 %]"  onClick="location='/auth/fs_newuser.pl'">
</form>
