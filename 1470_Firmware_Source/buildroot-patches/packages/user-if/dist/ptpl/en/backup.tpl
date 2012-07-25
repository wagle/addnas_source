<SCRIPT language = "javascript">
	function restore_backup(){
		//expect reboot
		if(!confirm("[% lang.m18022 %]")){
			return;
		}
		ajaxCmd("restore_id="+getSelectedBackup()+"&backup_volume="+getSelectedVolume());
	}
	function delete_backup(){
		if(confirm("[% lang.m18023 %]")){
			ajaxCmd("delete_id=" + getSelectedBackup() + "&backup_volume=" + getSelectedVolume());
		}
	}
	function new_backup(){
	       	var vol = getSelectedVolume();			
		bkcomment = document.getElementById("backup_comment").value;
		
		if(confirm("[% lang.m18024 %]")){
			ajaxCmd("new_backup=true&backup_volume=" + vol + "&backup_comment=" + bkcomment);
		}
	}
	function openVolume(vol){
		location.href = "/auth/backup.pl?backup_volume="+vol;
	}
	function getSelectedBackup(){
		var bkindex = document.getElementById("backup_id").selectedIndex;
		return document.getElementById("backup_id").options[bkindex].value;
	}

	function getSelectedVolume(){
		var bkvolindex = document.getElementById("backup_volume").selectedIndex;
		return document.getElementById("backup_volume").options[bkvolindex].value;
	}
	function ajaxCmd(cmd){
		var url = "/auth/backup.pl";	
		var xhr = false;
		if (window.ActiveXObject){
			xhr = new ActiveXObject("Microsoft.XMLHTTP");
		}
		else {
			xhr = new XMLHttpRequest();
		}
		xhr.open("GET",url+"?"+cmd,true);
  		xhr.send(null);
		xhr.onreadystatechange = function() {//Call a function when the state changes.
			location.href = url + "?backup_volume=" + getSelectedVolume(); 
		}
		
	}	
</SCRIPT>
	[% lang.e16000 %]		
	<br>
	<table width="100%" height="100%" border="0" cellpadding="10" cellspacing="0"> 
          <tr>
            	<td valign="top" class="PageTitle">
			[% backup_table %]
		</td>
          </tr>
        </table> 
