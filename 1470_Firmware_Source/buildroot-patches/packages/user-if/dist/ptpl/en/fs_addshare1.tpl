<script language="JavaScript">
</script>
<p class="PageTitle">[% lang.m11004 %]</p>
<br />
<form action="/auth/fs_addshare.pl" method="post">
[% lang.m11005 %] : <input type="text" name="sharename" id="sharename" tabindex="1" value="[% frm.sharename %]" size="32" maxlength="32"> <span class="valerror">[% err.sharename %]</span>
<br />
<br />
<input type="submit" name="submit" tabindex="2" value="[% lang.m08009 %]" >
<br />
<br />
<br />
<br />
<input type="button" name="back" tabindex="3" value="[% lang.m08021 %]"  onClick="location='/auth/fs_addshare.pl'">
<input type="button" name="cancel" tabindex="4" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<input type="hidden" name="cif" value="y">
<input type="hidden" name="sharename" value="[% frm.sharename %]" >
<input type="hidden" name="volume" value="[% frm.volume %]" >
<input type="hidden" name="nextstage" value="4">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "sharename" [% END %] ).focus();
</script>
<input type="hidden" name="nextstage" value="1" >

</form>
