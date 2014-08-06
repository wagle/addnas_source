<p class="PageTitle">[% lang.m16009 %]</p>
<br />
<form action="/auth/dm_formatExternal.pl" method="post">

<h3>[% lang.m16017 %]</h3>
[% IF frm.numberofdevices > 0 %]
<select name="device">
[% FOREACH device IN frm.devices %]
  <option value="[% device.id %]">[% device.name %]</option>
[% END %]
</select>
<select name="pttype">
  <option value="gpt">GPT</option> 
  <!-- <option value="gpt">GPT - > 2TB</option> --> 
  <!-- <option value="msdos">MBR - 2TB Max</option> -->
</select>
<select name="fstype">
  <!-- <option value="ext3">Linux EXT3</option> -->
  <option value="xfs">Linux XFS</option>
</select>
<input type="submit" name="b_format" tabindex="1" value="[% lang.m16009 %]" >
[% END %]
<input type="submit" name="b_cancel" tabindex="2" value="[% lang.m16004 %]" >
</form>
