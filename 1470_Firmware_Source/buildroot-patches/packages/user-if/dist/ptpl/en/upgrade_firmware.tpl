        <SCRIPT LANGUAGE=JAVASCRIPT>
	 	function verify(){
			msg = "[% lang.m18014 %]";
			return confirm(msg);
		}
	</SCRIPT>			
	<table width="100%" height="100%" border="0" cellpadding="10" cellspacing="0"> 
          <tr>
            <td valign="top" class="PageTitle">
                <form action="/auth/upgrade_firmware.pl" method="post" onSubmit="return verify()">
			<input type="hidden" name="downloading" value="true"/>
			<table>
				<!--
				<tr><td>URL : [% url %] </td></tr>
				<tr><td>Username : [% username %] </td></tr>
				<tr><td>Password : [% pwd %] </td></tr>
				<tr><td>Script output : [% scriptout %] </td></tr>
				--> 
				<tr><td>URL </td> <td><input type="text" size=60 name="url"/> </td></tr>
				<!--
				<tr><td>User</td> <td><input type="text" size=30 name="username"/></td></tr>
				<tr><td>PWD </td> <td><input type="password" size=30 name="pwd" /></td></tr>
				-->
			<tr><td></td><td align="left"><input type="submit" value="Upgrade"/></td></tr>
			</table>		
		</form>
              </td>
          </tr>
        </table>
