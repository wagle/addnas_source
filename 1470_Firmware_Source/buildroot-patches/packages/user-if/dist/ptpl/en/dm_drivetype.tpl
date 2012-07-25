<p class="PageTitle">[% lang.m16001 %]</p>
<br />
<form action="/auth/dm_drivetype.pl" method="post">
[% IF frm.drive_type %]
<h3>[% lang.m16005 %]</h3>
<h4>[% lang.m16023 %] [% frm.drive_type %]</h4>
<br/>
<input type="radio" name="drive_type" value="raid0"[% IF frm.drive_type == 'raid0' %] checked[% END %]>[% lang.m16006 %]
<br/>
<input type="radio" name="drive_type" value="raid1"[% IF frm.drive_type == 'raid1' %] checked[% END %]>[% lang.m16007 %]
<br/>
<br/>
<input type="submit" name="b_change_drive_type" tabindex="1" value="[% lang.m16008 %]" >
<input type="submit" name="b_cancel" tabindex="2" value="[% lang.m16004 %]" >
[% ELSE %]
<h4>[% lang.m16008 %]</h4>
[% lang.m18013 %]
<br/>
<input type="submit" name="b_cancel" tabindex="2" value="[% lang.m16004 %]" >
[% END %]
</form>
