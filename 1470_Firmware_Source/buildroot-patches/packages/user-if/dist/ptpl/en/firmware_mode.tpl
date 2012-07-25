<p class="PageTitle">[% lang.m18003 %]</p>
<br />
<br />
<p>[% lang.m18003 %]
</p>
<form action="firmware_upgrade.pl" method="post">
[% lang.m18010 %] <input type="text" name="fwserver" id="fwserver" tabindex="1" size="30" maxlength="100" value="[% frm.fwserver %]">&#x0020;
<input type="submit" name="go" tabindex="2" value="Go" ><br />

<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "fwserver" [% END %] ).focus();
</script>
</form>
