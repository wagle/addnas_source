<script language="JavaScript">
function isValid(tf) {
	if (!isPopulated(tf.new_sharename)) {
		tf.new_sharename.focus();
		alert("[% lang.e12001 %]");
		return false;
	}
}
</script>

<p class="PageTitle">[% lang.m12001 %]</p>
<form action="/auth/fs_renameshare.pl" method="post" onSubmit="return isValid(this);">

[% IF shares.size() %]

<p>[% lang.m12003 %]</p>
<br />

[% lang.m12005 %] <select name="sharename" tabindex="2" size="1">
[% FOREACH sh IN shares %]
<option value="[% sh.name %]"[% IF sh.name == frm.sharename %] SELECTED[% END %]>[% sh.name %]</option>
[% END %]
</select>
<br />
[% lang.m12004 %]: <input type="text" name="new_sharename" id="new_sharename" tabindex="1" size="32" maxlength="32" value="[% frm.new_sharename %]"><span class="valerror">[% err.new_sharename %]</span>
<br />
<br />
<input type="submit" name="submit" value="[% lang.m12002 %]" tabindex="3" >
<input type="hidden" name="nextstage" value="1" >
<input type="button" name="cancel" tabindex="4" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "new_sharename" [% END %] ).focus();
</script>
[% ELSE %]
	<p>[% lang.m14016 %]</p>
	<p>[% lang.m14015 %]</p>
	<br />
[% END %]

</form>
