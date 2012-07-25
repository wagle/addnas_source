<p class="PageTitle">[% lang.m08001 %] - [% lang.m08005 %] 1</p>
<p>
[% lang.m08006 %]
</p>
<form action="/auth/updnetwork.pl" method="post">
<select name="method" size="1">
  <option value="a" [% IF frm.method == "a" %] SELECTED[% END %]>[% lang.m08007 %]</option>
  <option value="m" [% IF frm.method == "m" %] SELECTED[% END %]>[% lang.m08008 %]</option>
</select>
<br />
<br />
<input type="submit" name="submit" tabindex="1" value="[% lang.m08009 %]" >
<br />
<br />
<br />
<br />

<input type="button" name="back" tabindex="2" value="[% lang.m08021 %]"  onClick="location='/auth/updnetwork.pl'">
<input type="button" name="cancel" tabindex="3" value="[% lang.m01027 %]"  onClick="location='/auth/gensetup.pl'">
<input type="hidden" name="nextstage" value="2">
</form>
