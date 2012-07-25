<p class="PageTitle">[% lang.m15001 %]</p>
<p>[% lang.m15002 %]</p>
[% lang.m15003 %]: <span style="font-weight: bold;">[% user.name %]</span>
<br />
<br />
<form action="/auth/fs_deluser.pl" method="post">
<input type="submit" name="submit" tabindex="1" value="[% lang.m15004 %]" >
&nbsp;
<input type="button" name="cancel" tabindex="2" value="[% lang.m01027 %]"  onClick="location='/auth/fs_userman.pl'">
<input type="hidden" name="nextstage" value="1" >
<input type="hidden" name="uid" value="[% user.uid %]" >
</form>
