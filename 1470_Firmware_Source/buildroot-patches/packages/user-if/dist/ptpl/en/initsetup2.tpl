

<p class="PageTitle">[% lang.m04005 %]</p>
<form action="/auth/initsetup.pl" method="post" >
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
<input type="submit" name="submit" tabindex="4" value="[% lang.m04006 %] >>" >
<input type="button" name="cancel" disabled  tabindex="5" value="[% lang.m04007 %]"  onClick="location='/auth/home.pl'">
<input type="hidden" name="nextstage" value="3">
<input type="hidden" name="timezonechange" value="0" >
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "username" [% END %] ).focus();
</script>
</form>
