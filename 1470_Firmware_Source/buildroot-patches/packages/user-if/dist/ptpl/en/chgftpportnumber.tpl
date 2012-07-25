<script language="JavaScript">
function isValid(tf) {

	if (!isInteger(tf.ftpportnumber)) {
		tf.username.focus();
		alert("[% lang.e21001 %]");
		return false;
	}
	return true;
}
</script>

<p class="PageTitle">[% lang.m21004 %]</p>
<form action="/auth/chgftpportnumber.pl" method="post" onSubmit="return isValid(this);">
<table border="0">
<tr>
	<td>[% lang.m21001 %]:</td>
	<td><input type="text" name="ftpportnumber" id="ftpportnumber" size="5" maxsize="5" value="[% frm.ftpportnumber %]" tabindex="1"><span class="valerror">[% err.ftpportnumber %]</span></td>
</tr>
</table>
<br />
<p>[% lang.m01041 %]</p>
<br />
<input type="submit" name="submit" value="[% lang.m01028 %]" tabindex="2" >
<input type="button" name="cancel" value="[% lang.m01027 %]"  onClick="location='/auth/gensetup.pl'" tabindex="3">
<input type="hidden" name="nextstage" value="1">

<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "ftpportnumber" [% END %] ).focus();
</script>
</form>
