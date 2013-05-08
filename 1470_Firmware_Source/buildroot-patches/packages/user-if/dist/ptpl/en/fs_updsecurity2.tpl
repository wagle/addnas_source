
<p class="PageTitle">[% lang.m14001 %]</p>
<form action="/auth/fs_updsecurity.pl" method="post">
<p>[% lang.m14013 %] [% frm.sharename %]</p>
<br />
<br />
[% IF frm.accessType != 'user' %]
[% lang.m14004 %]: <input type="password" name="pword1" id="pword1" tabindex="2" size="20" maxlength="21"> <span class="valerror">[% err.pword1 %]</span>
<br />
[% lang.m14005 %]: <input type="password" name="pword2" id="pword2" tabindex="3" size="20" maxlength="21"> <span class="valerror">[% err.pword2 %]</span>
<br />
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "pword1" [% END %] ).focus();
</script>
[% ELSE %]
<table border="1" width="100%">
<tr>
  <th align="left" rowspan="2">[% lang.m14007 %]</th>
  <th colspan="3">SMB</th>
  <th colspan="3">FTP</th>
</tr>
<tr>
  <th width="50px" align="left">[% lang.m10006 %]</th>
  <th width="50px" align="left">[% lang.m10007 %]</th>
  <th width="50px" align="left">[% lang.m10008 %]</th>
  <th width="50px" align="left">[% lang.m10006 %]</th>
  <th width="50px" align="left">[% lang.m10007 %]</th>
  <th width="50px" align="left">[% lang.m10008 %]</th>
</tr>
[% FOREACH user IN users %]
<tr>
  <td>[% user.name %]</td>
  <td><input type="radio" name="u_[% user.uid %]_smb_perm" value="f"[% IF user.smb_perm == "f" %] CHECKED[% END %]></td>
  <td><input type="radio" name="u_[% user.uid %]_smb_perm" value="r"[% IF user.smb_perm == "r" %] CHECKED[% END %]></td>
  <td><input type="radio" name="u_[% user.uid %]_smb_perm" value="n"[% IF user.smb_perm == "n" %] CHECKED[% END %]></td>
  <td><input type="radio" name="u_[% user.uid %]_ftp_perm" value="f"[% IF user.ftp_perm == "f" %] CHECKED[% END %]></td>
  <td><input type="radio" name="u_[% user.uid %]_ftp_perm" value="r"[% IF user.ftp_perm == "r" %] CHECKED[% END %]></td>
  <td><input type="radio" name="u_[% user.uid %]_ftp_perm" value="n"[% IF user.ftp_perm == "n" %] CHECKED[% END %]></td>
</tr>
[% END %]
</table>
<br />
[% lang.m14012 %]
</div>
[% END %]
<br />
<input type="hidden" name="sharename"  value="[% frm.sharename %]">
<input type="hidden" name="accessType" value="[% frm.accessType %]">
<input type="hidden" name="nextstage" value="2" >
<input type="submit" name="submit" tabindex="1" value="[% lang.m01028 %]" >
<input type="button" name="cancel" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<br />
<br />
</form>
