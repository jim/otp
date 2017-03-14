ObjC.import('stdlib')

var system = Application('System Events');
var zoom = system.processes["zoom.us"];

if (!Application("zoom.us").running()) {
  $.exit(0);
}

var window, i, title;

for (i = 0; i < zoom.windows.length; i++) {
  window = zoom.windows[i];
  title = window.title();
  if (title.indexOf('Meeting ID') !== -1 ||
      title.indexOf("Sharing Frame Window") !== -1) {
    $.exit(100);
  }
}

$.exit(0);
