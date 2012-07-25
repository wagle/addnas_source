<p class="PageTitle">[% lang.m11008 %]</p>
<br />
<form action="/auth/fs_addshare.pl" method="post">
<table>
	<tr>
        <td>[% lang.m11012 %] : </td>
        <!--td><input type="checkbox" name="real_cif" tabindex="2"  value="y" CHECKED DISABLED></td-->
        <td><input type="hidden" name="cif" value="y"></td>
        <td>[% lang.m11021 %]</td>
    </tr>
</table>
<br />
<!--
<br />
[% lang.m11010 %] : <input type="checkbox" name="http"  value="y">
<br />
[% lang.m11011 %] : <input type="checkbox" name="ftp"  value="y">
-->
<br />
<input type="submit" name="submit" tabindex="3" value="[% lang.m08009 %]" >
<br />
<br />
<br />
<br />
<input type="button" name="back" tabindex="4" value="[% lang.m08021 %]"  onClick="location='/auth/fs_addshare.pl'">
<input type="button" name="cancel" tabindex="5" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<input type="hidden" name="nextstage" value="4">
<input type="hidden" name="sharename" value="[% frm.sharename %]">
<input type="hidden" name="volume" value="[% frm.volume %]">
</form>
