
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
<table width="90%">
<tr> <th align="left">    </th> </tr>
<tr> <th align="left">    </th></tr>
<tr> <th align="left">[% lang.m14017 %]</th></tr>
<tr>
  <th align="left">[% lang.m14007 %]</th>
  <th align="left">[% lang.m14008 %]</th>
  <th align="left">[% lang.m14009 %]</th>
  <th align="left">[% lang.m14010 %]</th>
</tr>
[% FOREACH user IN users %]
<tr>
  <td>[% user.name %]</td>
  <td><input type="radio" name="u_[% user.uid %]_perm" value="f"[% IF user.perm == "f" %] CHECKED[% END %]></td>
  <td><input type="radio" name="u_[% user.uid %]_perm" value="r"[% IF user.perm == "r" %] CHECKED[% END %]></td>
  <td><input type="radio" name="u_[% user.uid %]_perm" value="n"[% IF user.perm == "n" %] CHECKED[% END %]></td>
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
