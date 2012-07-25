

<p class="PageTitle">[% lang.m06002 %]</p>
<form action="/auth/chgusername.pl" method="post" >
<br>
<table border="0">
<tr>
	<td>[% lang.m04001 %]:</td>
	<td><input type="text" name="username" id="username" tabindex="1" size="20" maxsize="20" value="[% frm.username %]"><span class="valerror">[% err.username %]</span></td>
</tr>
<tr>
	<td>[% lang.m04002 %]:</td>
	<td><input type="password" name="pword1" id="pword1" tabindex="2" size="20" maxsize="21"><span class="valerror">[% err.pword1 %]</span></td>
</tr>
<tr>
	<td>[% lang.m04003 %]:</td>
	<td><input type="password" name="pword2" id="pword2" tabindex="3" size="20" maxsize="21"><span class="valerror">[% err.pword2 %]</span></td>
</tr>
</table>
<br />
<input type="submit" name="submit" tabindex="4" value="[% lang.m01028 %] >>" >
<input type="button" name="cancel" tabindex="5" value="[% lang.m01027 %]"  onClick="location='/auth/gensetup.pl'">
<input type="hidden" name="nextstage" value="1">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "username" [% END %] ).focus();
</script>
</form>

