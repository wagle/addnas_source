
<p class="PageTitle">[% lang.m14001 %]</p>
[% IF shares.size() %]
	<p>[% lang.m14002 %]</p>
	<br />
	[% lang.m14003 %]
	<form action="/auth/fs_updsecurity.pl" method="post">
	 <select name="sharename" size="1" tabindex="1" >
	[% FOREACH sh IN shares %]
	<option value="[% sh.name %]"[% IF sh.name == frm.sharename %] SELECTED[% END %]>[% sh.name %]</option>
	[% END %]
	</select><span class="valerror">[% err.sharename %]</span>
	<br />
	<br />
	[% IF accessType != 'user' %]
		[% lang.m14004 %]: <input type="password" name="pword1" id="pword1" tabindex="2" size="20" maxlength="21"> <span class="valerror">[% err.pword1 %]</span>
		<br />
		[% lang.m14005 %]: <input type="password" name="pword2" id="pword2" tabindex="3" size="20" maxlength="21"> <span class="valerror">[% err.pword2 %]</span>
		<br />
		<script>
		document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "pword1" [% END %] ).focus();
		</script>
	[% ELSE %]
		[% lang.m14006 %]
		</div>
	[% END %]
	<br />
	<input type="hidden" name="nextstage" value="1" >
	<input type="hidden" name="accessType" value="[% accessType %]">
	<input type="submit" name="submit" tabindex="1" value="[% lang.m01036 %]" >
	<input type="button" name="cancel" value="[% lang.m01027 %]"  onClick="location='/auth/fileshare.pl'">
	</form>
[% ELSE %]
	<p>[% lang.m14016 %]</p>
	<p>[% lang.m14015 %]</p>
	<br />
[% END %]
