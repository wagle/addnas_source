<p class="PageTitle">[% lang.m05020 %]</p>
<h4>[% lang.m05022 %]</h4>
[% lang.m04001 %]: [% frm.username %]
<br/>
[% lang.m05003 %]: [% frm.date_string %]
<br/>
[% lang.m05004 %]: [% frm.new_hh %]:[% frm.new_min %]
<br/>
[% lang.m05005 %]: [% frm.new_timezone %]
<br>
<p>
[% lang.m05021 %]
</p>
<form action="/auth/initsetup.pl" method="post">
<input type="button" name="cancel" value="[% lang.m05024 %]"  onClick="location='/auth/home.pl'">
<input type="button" name="submit" value="[% lang.m05023 %]"  onClick="location='/home.pl'">
</form>
