<table width="90%">
<p> [% lang.m14017 %] </p>
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
<input type="submit" name="submit" tabindex="1" value="[% lang.m14011 %]" >
