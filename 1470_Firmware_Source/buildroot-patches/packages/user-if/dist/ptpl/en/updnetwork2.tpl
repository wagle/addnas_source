<script language="JavaScript" src="/validate.js">
</script>
<script>
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

<p class="PageTitle">[% lang.m08005 %] 2 : [% lang.m08010 %]</p>
<form action="/auth/updnetwork.pl" id="netForm" method="post" >
<p>
[% lang.m08011 %]: 
<br>
<input type="text" name="ip1" id="ip1" tabindex="1" size="3" maxlength="3" value="[% frm.ip1 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="ip2" id="ip2" tabindex="2" size="3" maxlength="3" value="[% frm.ip2 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="ip3" id="ip3" tabindex="3" size="3" maxlength="3" value="[% frm.ip3 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="ip4" id="ip4" tabindex="4" size="3" maxlength="3" value="[% frm.ip4 %]" onkeyup="cursorJump(this)"> 
<span class="valerror">[% err.ip %]</span>
<br>
<br>
[% lang.m08022 %]: 
<br>
<input type="text" name="msk1" id="msk1" tabindex="5" size="3" maxlength="3" value="[% frm.msk1 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="msk2" id="msk2" tabindex="6" size="3" maxlength="3" value="[% frm.msk2 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="msk3" id="msk3" tabindex="7" size="3" maxlength="3" value="[% frm.msk3 %]" onkeyup="cursorJump(this)"> .
<input type="text" name="msk4" id="msk4" tabindex="8" size="3" maxlength="3" value="[% frm.msk4 %]" onkeyup="cursorJump(this)"> 
<span class="valerror">[% err.msk %]</span>
<br />
</p>
<p>
[% lang.m08020 %]<br>
<br>
<input type="submit" name="submit" tabindex="9" value="[% lang.m08013 %] >>" >
<br />
<br />
<br />
<br />

<input type="button" name="back" tabindex="10" value="[% lang.m08021 %]"  onClick="location='/auth/updnetwork.pl'">
<input type="button" name="cancel" tabindex="11" value="[% lang.m01027 %]"  onClick="location='/auth/gensetup.pl'">
</p>
<input type="hidden" name="nextstage" value="3">
<input type="hidden" name="method" value="[% frm.method %]">
<script>
document.getElementById( [% IF focusOn %] "[% focusOn %]" [% ELSE %] "ip1" [% END %] ).focus();
</script>
</form>
