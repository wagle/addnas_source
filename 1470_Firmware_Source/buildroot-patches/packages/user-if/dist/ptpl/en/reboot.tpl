<SCRIPT LANGUAGE=JAVASCRIPT>
		function reboot(){
			document.getElementById('rbmsg').innerHTML = "<h4>[% lang.m18021 %]</h4>";
			document.getElementById('rbbutton').style.visibility = 'hidden';
			
			var xhr = false;
			if (window.ActiveXObject){
				xhr = new ActiveXObject("Microsoft.XMLHTTP");
			}
			else {
				xhr = new XMLHttpRequest();
			}
			xhr.open("GET","/auth/reboot.pl?rebooting=true",true);
  			xhr.send(null);
		}
		function useHttpResponse() {
  			if (xhr.readyState == 4) {
    				var textout = http.responseText;
    				document.getElementById('rbmsg').innerHTML = textout;
  			}
		}

	 	function verify(){
			msg = "[% lang.m18019 %]";
			if(confirm(msg)){
				reboot();		
			}
		}
</SCRIPT>	
[% lang.m19001 %]
<br>
<div id="rbmsg"></div>
<div id="rbbutton">
<input type="button"  value="Reboot" onClick="verify()">
</div>
