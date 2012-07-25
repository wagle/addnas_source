<p class="PageTitle">[% title %]</p>
<br />
<form action="[% handler %]" method="post">
<h4>[% warning %]</h4>
<h4>[% lang.m16030 %]</h4>
<input type="hidden" name="data" value="[% data %]">
<input type="hidden" name="fstype" value="[% fstype %]">
<input type="hidden" name="pttype" value="[% pttype %]">
<input type="submit" name="b_confirm" tabindex="1" value="[% lang.m16013 %]">
<input type="submit" name="b_cancel" tabindex="2" value="[% lang.m16004 %]">
</form>
