<script language="JavaScript">
</script>
<p class="PageTitle">[% lang.m11004 %]</p>
<br />
<form action="/auth/fs_addshare.pl" method="post">
[% lang.m11005 %] : <input type="text" name="sharename" id="sharename" tabindex="1" value="[% frm.sharename %]" size="32" maxlength="32"> <span class="valerror">[% err.sharename %]</span>
<br />
<br />
<input type="submit" name="submit1" tabindex="2" value="[% lang.m08009 %]" >
<br />
<br />
[% lang.m11022 %] : <select name="folder" size="1">
[% FOREACH ex IN extfolders %]
<option value="[% ex.path %]">[% ex.path %]</option>
[% END %]
</select>
<br />
<br />
<input type="submit" name="submit2" tabindex="3" value="[% lang.m08009 %]" >
<br />
<br />
<br />
<input type="submit" name="submit3" tabindex="4" value="[% lang.m08023 %]" >
<br />
<br />
<br />
<input type="button" name="back" tabindex="5" value="[% lang.m08021 %]"  onClick="location='/auth/fs_addshare.pl'">
<input type="button" name="cancel" tabindex="6" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<input type="hidden" name="cif" value="y">
<input type="hidden" name="sharename" value="[% frm.sharename %]" >
<input type="hidden" name="volume" value="[% frm.volume %]" >
<input type="hidden" name="nextstage" value="4">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "sharename" [% END %] ).focus();
</script>
<input type="hidden" name="nextstage" value="1" >

</form>
