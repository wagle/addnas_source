<p class="PageTitle">[% lang.m16024 %]</p>
<br />
[% IF frm.showform == 1 %]
<form action="/auth/dm_removeUSBdevice.pl" method="post">
[% IF frm.numberofdevices > 0 %]
    <select name="device">
    [% FOREACH device IN frm.devices %]
	<option value="[% device.id %]">[% device.name %]</option>
    [% END %]
    </select>
    <input type="hidden" name="dofunc" value="remove">
    <input type="submit" name="submit" tabindex="1" value="Remove" >
[% ELSE %]

[% END %]
    <!--<input type="submit" name="b_cancel" tabindex="1" value="[% lang.m16004 %]" -->
</form>

[% ELSE %]
    [% frm.devicename %]
    [% lang.m16036 %]

[% END %]
