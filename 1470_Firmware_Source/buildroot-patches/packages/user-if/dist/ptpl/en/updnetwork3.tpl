<script language="JavaScript" src="/validate.js">
</script>
<script language="JavaScript">
function cursorJump(x)
{
//    if (x.value.length==x.maxLength)
//	{
//        var next=x.tabIndex
//        if (next<document.getElementById("netForm").length)
//        {
//            document.getElementById("netForm").elements[next].focus()
//        }
//    }
}
</script>

<p class="PageTitle">[% lang.m08005 %] 3 : [% lang.m08014 %]</p>
<form action="/auth/updnetwork.pl" id="netForm" method="post" >
[% lang.m08014 %]: 
<br/>
<input type="text" name="gw1" id="gw1" tabindex="1" size="3" maxlength="3" value="[% frm.gw1 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="gw2" id="gw2" tabindex="2" size="3" maxlength="3" value="[% frm.gw2 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="gw3" id="gw3" tabindex="3" size="3" maxlength="3" value="[% frm.gw3 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="gw4" id="gw4" tabindex="4" size="3" maxlength="3" value="[% frm.gw4 %]" onkeyup="cursorJump(this)">
<span class="valerror">[% err.gw %]</span>
<br/>
<br/>
[% lang.m08018 %]: 
<br/>
<input type="text" name="dns11" id="dns11" tabindex="5" size="3" maxlength="3" value="[% frm.dns11 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns12" id="dns12" tabindex="6" size="3" maxlength="3" value="[% frm.dns12 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns13" id="dns13" tabindex="7" size="3" maxlength="3" value="[% frm.dns13 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns14" id="dns14" tabindex="8" size="3" maxlength="3" value="[% frm.dns14 %]" onkeyup="cursorJump(this)">
<span class="valerror">[% err.dns1 %]</span>
<br/>
<input type="text" name="dns21" id="dns21" tabindex="9"  size="3" maxlength="3" value="[% frm.dns21 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns22" id="dns22" tabindex="10" size="3" maxlength="3" value="[% frm.dns22 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns23" id="dns23" tabindex="11" size="3" maxlength="3" value="[% frm.dns23 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns24" id="dns24" tabindex="12" size="3" maxlength="3" value="[% frm.dns24 %]" onkeyup="cursorJump(this)">
<span class="valerror">[% err.dns2 %]</span>
<br/>
<input type="text" name="dns31" id="dns31" tabindex="13" size="3" maxlength="3" value="[% frm.dns31 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns32" id="dns32" tabindex="14" size="3" maxlength="3" value="[% frm.dns32 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns33" id="dns33" tabindex="15" size="3" maxlength="3" value="[% frm.dns33 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="dns34" id="dns34" tabindex="16" size="3" maxlength="3" value="[% frm.dns34 %]" onkeyup="cursorJump(this)">
<span class="valerror">[% err.dns3 %]</span>
<br/>
<br/>
[% lang.m08019 %]: 
<br />
<input type="text" name="ntp" id="ntp" tabindex="17" size="60" maxlength="128" value="[% frm.ntp %]">
<span class="valerror">[% err.ntp %]</span>
<br />
<br />
<input type="submit" name="submit" tabindex="18" value="[% lang.m08009 %]" >
<br />
<br />
<br />
<br />

<input type="button" name="back" tabindex="19" value="[% lang.m08021 %]"  onClick="location='/auth/updnetwork.pl'">
<input type="button" name="cancel" tabindex="20" value="[% lang.m01027 %]"  onClick="location='/auth/gensetup.pl'">
<input type="hidden" name="nextstage" value="4">
<input type="hidden" name="ip" value="[% frm.ip %]">
<input type="hidden" name="sn" value="[% frm.sn %]">
<input type="hidden" name="msk" value="[% frm.msk %]">
<input type="hidden" name="method" value="[% frm.method %]">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "gw1" [% END %] ).focus();
</script>
</form>
