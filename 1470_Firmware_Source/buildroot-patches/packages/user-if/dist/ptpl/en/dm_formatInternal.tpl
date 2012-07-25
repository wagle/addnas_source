<p class="PageTitle">[% lang.m16001 %]</p>
<br />
<form action="/auth/dm_formatInternal.pl" method="post">
[% IF frm.replacement %]
<h3>[% lang.m16020 %]</h3>
<h4>[% lang.m16023 %] [% frm.drive_type %]</h4>
<h4>[% lang.m16033 %] [% frm.replacement %]</h4>
</br>
</br>
<input type="submit" name="b_format" tabindex="1" value="[% lang.m16010 %]" >
<input type="submit" name="b_cancel" tabindex="2" value="[% lang.m16004 %]" >
[% ELSE %]
<h4>[% lang.m16010 %]</h4>
[% lang.m16021 %]
</br>
<input type="submit" name="b_cancel" tabindex="1" value="[% lang.m16004 %]" >
[% END %]
</form>
