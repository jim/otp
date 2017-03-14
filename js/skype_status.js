ObjC.import('stdlib')

// Based on https://github.com/monterail/Skype-Call-HipChat-Status/blob/master/SkypeHipchat.js

var skype = Application("Skype");

function sendCommand(command) {
  return skype.send({command: command, scriptName: "otp"});
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
