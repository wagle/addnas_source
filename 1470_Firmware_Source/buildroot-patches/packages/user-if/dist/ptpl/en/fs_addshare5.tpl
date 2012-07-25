<p class="PageTitle">[% lang.m11016 %]</p>
<br />
<br />
<p>
[% lang.m11017 %]
</p>
<br />
<br />
<form action="/auth/fs_addshare.pl" method="post">
<input type="submit" name="submit" tabindex="1" value="[% lang.m11018 %]" >
<br />
<br />
<br />
<br />
<input type="button" name="back" tabindex="2" value="[% lang.m08021 %]"  onClick="location='/auth/fs_addshare.pl'">
<input type="button" name="cancel" tabindex="3" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<input type="hidden" name="nextstage" value="6">

<input type="hidden" name="nfs_public" value="[% frm.nfs_public %]">
[% FOREACH user IN users %]
<input type="hidden" name="user_[% user.id %]_perm" value="[% user.perm %]">
[% END %]

<input type="hidden" name="sharename" value="[% frm.sharename %]" >
<input type="hidden" name="pword" value="[% frm.pword1 %]" >
<input type="hidden" name="cif" value="[% frm.cif %]" >
<input type="hidden" name="http" value="[% frm.http %]" >
<input type="hidden" name="nfs" value="[% frm.nfs %]" >
<input type="hidden" name="ftp" value="[% frm.ftp %]" >
<input type="hidden" name="volume" value="[% frm.volume %]" >
</form>
