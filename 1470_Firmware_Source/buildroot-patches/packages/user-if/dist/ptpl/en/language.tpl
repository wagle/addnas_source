<form action="/auth/language.pl" method="post">
<table width="100%" height="100%" border="0" cellpadding="10" cellspacing="0"> 
<tr>
	<td valign="top" colspan="2" class="PageTitle"><p><br>[% lang.m03001 %]</p></td>
</tr>
<tr>
	<td>[% lang.m03002 %]:</td>
	<td><select name="lang" size="1">
		<option value="en">[% lang.m03003 %]</option>
		</select>
	</td>
</tr>
</table>
<input type="submit" name="submit" tabindex="1" value="[% lang.m01025 %]" >
<input type="button" name="cancel" tabindex="2" value="[% lang.m01027 %]"  onClick="location='/'">
</form>
