ObjC.import('stdlib')

// Based on https://github.com/monterail/Skype-Call-HipChat-Status/blob/master/SkypeHipchat.js

var skype = Application("Skype");

function sendCommand(command) {
  var result;
  try {
    result = skype.send({command: command, scriptName: "otp"});
  } catch(e) {
    console.log(e.message);
    $.exit(0);
  }
}

if (!skype.running()) {
  $.exit(0);
}

var calls = sendCommand("SEARCH ACTIVECALLS");
var callIds = calls.split(" ");
callIds.unshift(); // remove CALLS

callIds.forEach(function(id) {
  var status = sendCommand("GET CALL " + id + " STATUS");

  if (/INPROGRESS/.test(status)) {
    $.exit(100);
  }
});

$.exit(0);
