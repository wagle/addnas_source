<p class="PageTitle">[% lang.m16011 %]</p>
<br />
<form action="/auth/dm_formatInternal.pl" method="post">

<h3>[% lang.m16022 %]</h3>

<h4>[% lang.m16018 %] [% frm.deviceName %]</h4>
<input type="hidden" name="deviceName" value="[% frm.deviceName %]" >
<input type="hidden" name="device" value="[% frm.device %]" >
[% IF device %]
<input type="submit" name="b_format" tabindex="1" value="[% lang.m16009 %]" >
[% END %]
<input type="submit" name="b_cancel" tabindex="2" value="[% lang.m16004 %]" >
</form>
