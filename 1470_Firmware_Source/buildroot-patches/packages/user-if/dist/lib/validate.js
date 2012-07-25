function isEmptyText(tb, fname) {

	if (tb.value.length == 0) {
		return true;
	}
	return false;
}

function isEmptyLb(lb, fname) {

	if (lb.options[lb.selectedIndex].value.length == 0) {
		lb.focus();
		alert('Please choose a value for ' + fname);
		return true;
	}
	return false;
}
// Routines to enable validation of form text fields.
//

function isPopulated(inpObj)
{
	var re = /^\s+$/

    OK = re.exec(inpObj.value)
	if ((inpObj.value.length == 0) || OK)
	{
		return false
	}
	
	return true
}

function isInteger(inpObj)
{
	if (!isNumeric(inpObj))
		return false

	var intVal = parseInt(inpObj.value)

	if (isNaN(intVal))
	{
		return false
	}

	if (intVal != inpObj.value)
	{
		return false
	}

	return true
}

function isNumeric(inpObj)
{
	if (!isPopulated(inpObj)) {
		return true;
	}

	var floatVal = parseFloat(inpObj.value)

	if (isNaN(floatVal))
	{	
		return false
	}

	if (floatVal != inpObj.value)
	{
		return false
	}

	return true
}

// If a form has several fields, and the requirement is that at least one of
//	them must contain a value, use this function to check the fields.
//
// Takes a single array param which holds all fields to check.
//
function atLeastOne(formFields) {
	for (i=0; i<formFields.length; i++) {
		if (isPopulated(formFields[i], 'ignore', 1)) {
			return true
		}
	}
	formFields[0].focus()
	alert('Please fill in at least one field.')

	return false;
}

function timeCheck(timeval) {

	var re = /^(\d+):(\d{2})$/

	if (!re.test(timeval)) {
		alert('Invalid time value');
		return false;
	}	

	t = re.exec(timeval)
	if ((t[1] < 0) || (t[1] > 23)) {
		alert('Hours are invalid');
		return false;
	}

	if ((t[2] < 0) || (t[2] > 59)) {
		alert('Minutes are invalid');
		return false;
	}

	return true;

}

// Checks the validity of a network quad
//
