<p class="PageTitle">[% lang.m05019 %]</p>
<SCRIPT type="text/javascript" language="JavaScript" >
    function timeZoneChange() {
        document.inittimedate.nextstage.value = 3;
        document.inittimedate.timezonechange.value = 1;
        document.inittimedate.submit();
        
        return false;
    }
</SCRIPT>
<form action="/auth/initsetup.pl" name="inittimedate" method="post">
<table border="0">
<tr>
	<td>[% lang.m05001 %]:</td>
	<td>[% current_date %]</td>
</tr>
<tr>
	<td>[% lang.m05002 %]:</td>
	<td>[% current_time %]</td>
</tr>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
<tr>
	<td>[% lang.m05005 %]:</td>
	<td>
		<select name="new_timezone" onChange="timeZoneChange();" >
[% FOREACH z IN timezones %]
  <option value="[% z %]"[% IF z == frm.new_timezone %] SELECTED[% END %]>[% z %]</option>
[% END %]
		</select>
	</td>
</tr>
<tr>
	<td>[% lang.m05003 %]:</td>
	<td><select name="new_dd">
[% dd = 1 %]
[% WHILE dd < 32 %]
			<option value="[% dd %]"[% IF dd == frm.new_dd %] SELECTED[% END %]>[% dd %]</option>
[% dd=dd+1 %]
[% END %]
			</select>
			<select name="new_mon">
			<option value="1"[% IF frm.new_mon == 1 %] SELECTED[% END %]>[% lang.m05006 %]</option>
			<option value="2"[% IF frm.new_mon == 2 %] SELECTED[% END %]>[% lang.m05007 %]</option>
			<option value="3"[% IF frm.new_mon == 3 %] SELECTED[% END %]>[% lang.m05008 %]</option>
			<option value="4"[% IF frm.new_mon == 4 %] SELECTED[% END %]>[% lang.m05009 %]</option>
			<option value="5"[% IF frm.new_mon == 5 %] SELECTED[% END %]>[% lang.m05010 %]</option>
			<option value="6"[% IF frm.new_mon == 6 %] SELECTED[% END %]>[% lang.m05011 %]</option>
			<option value="7"[% IF frm.new_mon == 7 %] SELECTED[% END %]>[% lang.m05012 %]</option>
			<option value="8"[% IF frm.new_mon == 8 %] SELECTED[% END %]>[% lang.m05013 %]</option>
			<option value="9"[% IF frm.new_mon == 9 %] SELECTED[% END %]>[% lang.m05014 %]</option>
			<option value="10"[% IF frm.new_mon == 10 %] SELECTED[% END %]>[% lang.m05015 %]</option>
			<option value="11"[% IF frm.new_mon == 11 %] SELECTED[% END %]>[% lang.m05016 %]</option>
			<option value="12"[% IF frm.new_mon == 12 %] SELECTED[% END %]>[% lang.m05017 %]</option>
			</select>
			<select name="new_yyyy">
[% yy = 2006 %]
[% WHILE yy < 2021 %]
			<option value="[% yy %]" [% IF yy == frm.new_yyyy %] SELECTED[% END %]>[% yy %]</option>
[% yy=yy+1 %]
[% END %]
			</select>
			<span class="valerror">[% err.date %]</span>
	</td>
</tr>
<tr>
	<td>[% lang.m05004 %]:</td>
	<td>
		<select name="new_hh">
[% hh=0 %]
[% WHILE hh < 24 %]
                [% IF hh < 10 %]
                        [% hh = '0' _ hh %]
                [% END %]
		<option value="[% hh %]"[% IF hh == frm.new_hh %] SELECTED[% END %]>[% hh %]</option>
[% hh=hh+1 %]
[% END %]
		</select>
:
		<select name="new_min">
[% min=0 %]
[% WHILE min < 60 %]
                [% IF min < 10 %]
                        [% min = '0' _ min %]
                [% END %]

		<option value="[% min %]"[% IF min == frm.new_min %] SELECTED[% END %]>[% min %]</option>
[% min=min+1 %]
[% END %]
		</select>
		<span class="valerror">[% err.time %]</span>
	</td>
</tr>
</table>
<br />
<br />
<input type="submit" tabindex="1" value="[% lang.m04006 %] >>" >
<input type="button" name="cancel" tabindex="2" value="[% lang.m04007 %]"  onClick="location='/auth/home.pl'">
<input type="hidden" name="nextstage" value="4">
<input type="hidden" name="username" value="[% frm.username %]">
<input type="hidden" name="pword" value="[% frm.pword %]">
<input type="hidden" name="timezonechange" value="0" >
</form>
