<script language="JavaScript">
function isValid(tf) {
	if (!isPopulated(tf.confirm)) {
		tf.confirm.focus();
		alert('[% lang.e13001 %]');
		return false;
	}

  if (tf.confirm.value != '[% lang.m13005 %]') {
		tf.confirm.focus();
		alert('[% lang.e13001 %]');
		return false;
  }
}
</script>

<p class="PageTitle">[% lang.m13001 %]</p>
<form action="/auth/fs_removeshare.pl" method="post" onSubmit="return isValid(this);">

[% IF shares.size()  %]
<p>[% lang.m13002 %]</p>
<p>[% lang.m13003 %]</p>
<br />
[% lang.m13006 %] <select name="sharename" size="1">
[% FOREACH sh IN shares %]
<option value="[% sh.name %]"[% IF sh.name == frm.sharename %] SELECTED[% END %]>[% sh.name %]</option>
[% END %]
</select>
<br />
<p>[% lang.m13004 %]<input type="text" name="confirm" id="confirm" tabindex="1" size="3" maxlength="3" autocomplete="off" value="[% frm.confirm %]"></p>
<input type="submit" name="submit2" tabindex="2" value="[% lang.m13008 %]" >
<input type="submit" name="submit1" tabindex="3" value="[% lang.m13007 %]" >
<input type="hidden" name="nextstage" value="1" >
<input type="button" name="cancel" tabindex="4" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "confirm" [% END %] ).focus();
</script>
[% ELSE %]
	<p>[% lang.m14016 %]</p>
	<p>[% lang.m14015 %]</p>
	<br />
[% END %]
</form>
