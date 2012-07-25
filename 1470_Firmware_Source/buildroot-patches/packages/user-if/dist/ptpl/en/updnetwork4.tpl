
<p class="PageTitle">[% lang.m08015 %]</p>
<form action="/auth/updnetwork.pl" method="post" >
<p>[% lang.m01035 %]</p>
<br />
<input type="submit" name="submit" value="[% lang.m01026 %]" >
<br />
<br />
<input type="hidden" name="method" value="[% frm.method %]" >   
<input type="hidden" name="warning"   value="[% frm.warning %]">          
<input type="hidden" name="ip"   value="[% frm.ip %]">          
<input type="hidden" name="sn"   value="[% frm.sn %]">          
<input type="hidden" name="msk"  value="[% frm.msk %]">          
<input type="hidden" name="gw"   value="[% frm.gw %]">          
<input type="hidden" name="ntp"  value="[% frm.ntp %]">         
<input type="hidden" name="dns1" value="[% frm.dns1 %]">        
<input type="hidden" name="dns2" value="[% frm.dns2 %]">        
<input type="hidden" name="dns3" value="[% frm.dns3 %]">        
<input type="button" name="back" tabindex="1" value="[% lang.m08021 %]"  onClick="location='/auth/updnetwork.pl'">
<input type="button" name="cancel" tabindex="2" value="[% lang.m01027 %]"  onClick="location='/auth/gensetup.pl'">
<input type="hidden" name="nextstage" value="5">
<br />
</form>
