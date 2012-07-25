


<p class="PageTitle">[% lang.m11013 %]</p>
<br />
<p>
[% lang.m11014 %]
</p>
<form action="/auth/fs_addshare.pl" method="post" >
[% lang.m04002 %] <input type="password" name="pword1" id="pword1" tabindex="1" size="20" maxlength="21"><span class="valerror">[% err.pword1 %]</span>
<br />
[% lang.m04003 %] <input type="password" name="pword2" id="pword2" tabindex="2" size="20" maxlength="21"><span class="valerror">[% err.pword2 %]</span>
<br />
<br />
<input type="submit" name="submit" tabindex="3" value="[% lang.m08009 %]" >
<br />
<br />
<br />
<br />
<input type="button" name="back" tabindex="4" value="[% lang.m08021 %]"  onClick="location='/auth/fs_addshare.pl'">
<input type="button" name="cancel" tabindex="5" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">

<input type="hidden" name="nextstage" value="5">
<input type="hidden" name="sharename" value="[% frm.sharename %]">
<input type="hidden" name="volume" value="[% frm.volume %]">
<input type="hidden" name="cif" value="[% frm.cif %]" >
<input type="hidden" name="http" value="[% frm.http %]" >
<input type="hidden" name="nfs" value="[% frm.nfs %]" >
<input type="hidden" name="ftp" value="[% frm.ftp %]" >
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "pword1" [% END %] ).focus();
</script>
</form>
