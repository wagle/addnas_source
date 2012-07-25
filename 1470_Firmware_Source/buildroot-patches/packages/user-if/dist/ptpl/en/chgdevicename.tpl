<script language="JavaScript">
function isValid(tf) {

	if (!isPopulated(tf.devicename)) {
		tf.username.focus();
		alert("[% lang.e07001 %]");
		return false;
	}

	if (!isPopulated(tf.workgroup)) {
		tf.pword1.focus();
		alert("[% lang.e07002 %]");
		return false;
	}

	return true;
}
</script>

<p class="PageTitle">[% lang.m07004 %]</p>
<form action="/auth/chgdevicename.pl" method="post" onSubmit="return isValid(this);">
<table border="0">
<tr>
	<td>[% lang.m07001 %]:</td>
	<td><input type="text" name="devicename" id="devicename" size="16" maxsize="16" value="[% frm.devicename %]" tabindex="1"><span class="valerror">[% err.devicename %]</span></td>
</tr>
<tr>
	<td>[% lang.m07002 %]:</td>
	<td><input type="text" name="workgroup" id="workgroup" size="16" maxsize="16" value="[% frm.workgroup %]" tabindex="2"><span class="valerror">[% err.workgroup %]</span></td>
</tr>
</table>
<br />
<p>[% lang.m01035 %]</p>
<br />
<input type="submit" name="submit" value="[% lang.m01028 %]" tabindex="3" >
<input type="button" name="cancel" value="[% lang.m01027 %]"  onClick="location='/auth/gensetup.pl'" tabindex="4">
<input type="hidden" name="nextstage" value="1">

<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "devicename" [% END %] ).focus();
</script>
</form>
