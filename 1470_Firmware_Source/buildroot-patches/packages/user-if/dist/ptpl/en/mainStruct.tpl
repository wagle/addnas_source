<html>
<head>
<title>[% lang.m01000 %]</title><style type="text/css">
<!--
body {
	margin-left: 10px;
	margin-top: 10px;
}
-->
</style>
[% head %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="/MBUI.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript">
// ===================================================
// tabclick: used for the top tabs to jump to a specific page
//===================================================
	function tabclick(daTab) {
		if (daTab == 1)
		{window.location = "/auth/home.pl";}
		else if (daTab == 2)
		{window.location = "/auth/gensetup.pl";}
		else if (daTab == 3)
		{window.location = "/auth/fileshare.pl";}
		else if (daTab == 4)
		{window.location = "/auth/p2pconf.pl";}
		else if (daTab == 5)
		{window.location = "/auth/upgrade_firmware.pl";}
	
	}
var xcord = 57;
// ===================================================
// moveArrow: used to place the mouseover arrow to the
//			right of the item. Send in y-cord (top cord)
//			x-cord should be same
//===================================================
function moveArrow(ycord) // vert cord of layer
{

// ignore this function
//
/*    if(document.layers)	   //NN4+
    {
       document.layers["MenuArrow"].moveToAbsolute(xcord,ycord);
    }
    else if(document.getElementById)	  //gecko(NN6) + IE 5+
    {
        var obj = document.getElementById("MenuArrow");
        obj.style.top = ycord;
    }
   else if(document.all)	// IE 4
    {
        document.all["MenuArrow"].style.top = ycord;
    }*/
}
</script>
<script language="JavaScript" src="/validate.js"></script>
<script language="JavaScript" src="/ajax.js"></script>
</head>

<body bgcolor="#FFFFFF" text="#000000">

<table width="1000" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top" align="left" background="/images/BG_header.jpg">
      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="Border_LRTB">
	<tr>
	  <td align="left" valign="top"><img src="/images/spacer.gif" width="290" height="1"></td>
	  <td valign="top" align="left"><img src="/images/spacer.gif" width="414" height="1"></td>
	  <td valign="top" align="left"><img src="/images/spacer.gif" width="296" height="1"></td>
	</tr>
	<tr>
	  <td valign="top" align="left"><img src="/images/spacer.gif" width="130" height="70"></td>
	  <td valign="middle" align="left">
	    <table width="100%" border="0" cellspacing="0" cellpadding="2">
	      <tr>
		<td class="headertitle"><div align="center">[% lang.m01000 %]</div></td>
	      </tr>
	    </table>
	  </td>
	  <td width="296" valign="middle" align="left">
	    <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
	      <tr>
		<td align="right" valign="top" class="headerdetails">[% lang.m01002 %]: </td>
		<td valign="top" class="headerdetails">[% fr_device_name %]</td>
	      </tr>
	      <tr>
		<td align="right" valign="top" class="headerdetails">[% lang.m01042 %]: </td>
		<td valign="top" class="headerdetails">[% fr_workgroup %]</td>
	      </tr>
	      <tr>
		<td align="right" valign="top" class="headerdetails">[% lang.m01003 %]:</td>
		<td valign="top" class="headerdetails">[% fr_firmware %]</td>
	      </tr>
	    </table>
	  </td>
	</tr>
	<tr>
	  <td colspan="3" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="2">

	    <tr>
	      <td width="30" align="left" valign="top"><img src="/images/spacer.gif" width="30" height="20"></td>
	      <td width="746" align="left" valign="middle" class="timestampwht"><div id="fr_datetime">[% fr_datetime %]</div></td>
	      <td width="212" align="right" valign="middle" class="headeruserboldwht">[% IF fr_username %][% lang.m01005 %]: [% fr_username %][% END %]&nbsp;&nbsp; </td>
	    </tr>
	  </table>
	</td>
      </tr>

    </table>
  </td>
</tr>
  <tr>
    <td align="left" valign="top">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td  colspan="2"  width="104" align="left" valign="top" bgcolor="#29478D">&nbsp;</td>
        <td colspan="2" valign="top" class="breadcrumb"><table width="100%" border="0" cellspacing="0" cellpadding="4">
            <tr>
              <td width="50%" align="left" valign="middle" class="breadcrumb"></td>

              <td align="right" valign="middle" class="breadcrumb">
<!--<a href="/auth/language.pl">[% lang.m01007 %]</a> |
<A href="http://www.addonics.com"> [% lang.m01009 %]</A>-->&nbsp;</td>
            </tr>
        </table></td>
      </tr>

	<tr>
  	<td align="left" valign="top" bgcolor="#29478D">&nbsp;</td>
        <td align="left" valign="top" bgcolor="#29478D" class="Border_bottom" >&nbsp;</td>
        <td align="left" valign="bottom" colspan="10"><table width="100%" border="0" cellspacing="0" cellpadding="0">

  <tr>
	[% SWITCH tabon %]
		[% CASE 'home' %]
			[% INCLUDE tab_bar_home.tpl %]
		[% CASE 'general' %]
			[% INCLUDE tab_bar_general.tpl %]
		[% CASE 'fileshare' %]
			[% INCLUDE tab_bar_fileshare.tpl %]
		[% CASE 'p2pconf' %]
			[% INCLUDE tab_bar_p2pconf.tpl %]
                [% CASE 'upgrade_firmware' %]
			[% INCLUDE tab_bar_upgrade_firmware.tpl %]
		[% CASE %]
			[% INCLUDE tab_bar_home.tpl %]
	[% END %]
  </tr>
</table></td>
<td>&nbsp;</td>
        </tr>


      <tr>
        <td bgcolor="#29478D" class="Border_bottom">&nbsp;</td>
        <td bgcolor="#d2dafe" class="Border_bottomleftrghtgry">&nbsp;</td>
        <td valign="top" colspan="9" class="Border_bottom">
<!-- Main Body -->
<div style="margin: 10px 10px 10px 10px;">
[% INCLUDE $mainBit %]
</div>
<!-- End of Main Body -->
		</td>
        <td align="center" valign="top"  class="Border_rightbottom"><p><br>
        </p>
      </tr>
      <tr>
        <td  width="104"  bgcolor="#29478D"><img src="/images/spacer.gif" width="46" height="1"></td>
        <td  width="104"  bgcolor="#d2dafe" class="Border_left"><img src="/images/spacer.gif" width="58" height="1"></td>
        <td width="601"><img src="/images/spacer.gif" width="601" height="1"></td>

        <td width="295" valign="top"><img src="/images/spacer.gif" width="295" height="1"></td>
        </tr>
    </table></td>
  </tr>
</table>
<!-- Footer -->
<table width="1000" border="0" cellspacing="0" cellpadding="0"><tr>
  <td align="center" class="footertext">
For Technical Support Contact: <a href="http://www.gdc-tech.com/english/technical.php">http://www.gdc-tech.com/english/technical.php</a> or phone USA +1 877 743 2872 (Toll Free)
<br>
<br>
Copyright &copy; 2011 Addonics Technologies, All rights reserved.
</td>
</tr></table>
<!-- End of Footer -->
<br/><br/>
</body>
</html>
