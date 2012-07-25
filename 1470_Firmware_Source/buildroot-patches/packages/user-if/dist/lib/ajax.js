// AJAX Functions
var req=null;
var READY_STATE_UNINITIALISED=0
var READY_STATE_LOADING=1
var READY_STATE_LOADED=2
var READY_STATE_INTERACTIVE=3
var READY_STATE_COMPLETE=4

var ajax_element=null;
var ajax_url=null;   
var ajax_message=''; 		// A default message displayed when no data was received  
var ajax_timeout=1000;   

function sendRequest(url, params, HttpMethod) {
	if (!HttpMethod) {
		HttpMethod="GET";
	}

	req=initXMLHTTPRequest();
	if (req) {
		req.onreadystatechange=onReadyState;
		req.open(HttpMethod, url, true);
		req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		req.send(params);
	}
}

function initXMLHTTPRequest() {
	var xRequest=null;
	if (window.XMLHttpRequest) {
		xRequest=new XMLHttpRequest();
	} else if (window.ActiveXObject) {
		xRequest=new ActiveXObject("Microsoft.XMLHTTP");
	}
	return xRequest;
}

function onReadyState() {
	var ready=req.readyState;
	var data=null;
	if (ready==READY_STATE_COMPLETE) {
		data=req.responseText;
		p = document.getElementById( ajax_element )
		if (data) {
			p.innerHTML = data;
		} else {
			p.innerHTML = ajax_message;
		}
		setTimeout( "fetch()", ajax_timeout );
	}
}

function fetch( url, element, timeout, defaultMessage ) {
	// Retry fetching the url into element every 1000ms
	if (url && element) {
		ajax_url = url;
		ajax_element = element;
	}
	if (timeout) {
		ajax_timeout = timeout;
	}
	if (defaultMessage) {
		ajax_message = defaultMessage;
	}
	sendRequest( ajax_url );
}
