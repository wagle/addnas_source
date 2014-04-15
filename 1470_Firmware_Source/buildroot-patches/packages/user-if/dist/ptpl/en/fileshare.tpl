<p class="PageTitle">[% lang.m09001 %]</p>
[% lang.m09018 %]
<br />
<br />
<table border="0" width="90%">
<tr>
  <th align="left">[% lang.m10005 %]</th>
  <th align="left">[% lang.m10010 %]</th>
  <th align="left">[% lang.m10011 %]</th>
  <th align="left">[% lang.m10014 %]</th>
[% IF accessType != 'user' %]
  <th>Access Type</th>
[% END %]
  <th>&nbsp;</th>
</tr>
[% FOREACH sh IN shares %]
<tr>
  <td>[% sh.name %]</td>
  <td>[% sh.drive %]</td>
  <td>[% sh.avail ? sh.avail : 'yes' %]</td>
  <td>[% sh.wholedisk ? 'yes' : 'no' %]</td>
[% IF accessType != 'user' %]
  <td>[% sh.accessType %]</td>
[% END %]
<!--
  <td><input type="button" value="[% lang.m09019 %]"></td>
-->
</tr>
[% END %]
</table>
<br />
<table width="100%" border="0" cellspacing="0" cellpadding="8">
  <tr>
    <td width="60" valign="top"><a href="/auth/fs_userman.pl"  onMouseOver="moveArrow(350)"></a></td>
    <td align="left" valign="top" class="PageTitle"><a href="/auth/fs_userman.pl" class="PageTitle" onMouseOver="moveArrow(350)">[% lang.m09012 %]</a></td>
  </tr>
<!--
  <tr>
    <td width="60" valign="top"><a href="/auth/fs_chgaccesstype.pl"  onMouseOver="moveArrow(240)"></a></td>
    <td align="left" valign="top" class="PageTitle"><a href="/auth/fs_chgaccesstype.pl" class="PageTitle" onMouseOver="moveArrow(330)">[% lang.m09002 %]</a></td>
  </tr>
-->
  <tr>
    <td valign="top"><a href="/auth/fs_addshare.pl"  onMouseOver="moveArrow(440)"></a></td>
    <td align="left" valign="top" ><a href="/auth/fs_addshare.pl"  class="PageTitle" onMouseOver="moveArrow(440)">[% lang.m09003 %]</a></td>
  </tr>
  <tr>
    <td valign="top"><a href="/auth/fs_renameshare.pl"  onMouseOver="moveArrow(530)"></a></td>
    <td align="left" valign="top"><a href="/auth/fs_renameshare.pl"  class="PageTitle" onMouseOver="moveArrow(530)">[% lang.m09004 %]</a></td>
  </tr>
  <tr>
    <td valign="top"><a href="/auth/fs_removeshare.pl"  onMouseOver="moveArrow(620)"></a></td>
    <td align="left" valign="top"><a href="/auth/fs_removeshare.pl"  class="PageTitle" onMouseOver="moveArrow(620)">[% lang.m09005 %]</a></td>
  </tr>
  <tr>
    <td valign="top"><a href="/auth/fs_updsecurity.pl"  onMouseOver="moveArrow(710)"></a></td>
    <td align="left" valign="top"><a href="/auth/fs_updsecurity.pl"  class="PageTitle" onMouseOver="moveArrow(710)">[% lang.m09006 %]</a></td>
  </tr>
</table>
