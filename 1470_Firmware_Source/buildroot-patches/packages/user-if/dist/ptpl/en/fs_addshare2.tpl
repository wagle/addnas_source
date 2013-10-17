<p class="PageTitle">[% lang.m11006 %]</p>
<br />
<form action="/auth/fs_addshare.pl" method="post">
[% lang.m11007 %] : <select name="volume" size="1">
<!--<option value="Main">Main</option>-->
[% FOREACH ex IN extvols %]
<option value="[% ex.path %]">[% ex.prefix %] [% ex.path %]</option>
[% END %]
</select>
<input type="hidden" name="sharename" value="[% frm.sharename %]" >
<br />
<br />
<input type="submit" name="submit" tabindex="1" value="[% lang.m08009 %]" >
<br />
<br />
<br />
<br />
<input type="button" name="back" tabindex="2" value="[% lang.m08021 %]"  onClick="location='/auth/fs_addshare.pl'">
<input type="button" name="cancel" tabindex="3" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
<input type="hidden" name="nextstage" value="2">
</form>
