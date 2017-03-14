ObjC.import('stdlib')

try {
  var chrome = Application('Google Chrome');
} catch(e) {
  // Chrome isn't running.
  $.exit(0);
}

var window, w, tab, t, title, url;

for (w = 0; w < chrome.windows.length; w++) {
  window = chrome.windows[w];
  for (t = 0; t < window.tabs.length; t++) {
    tab = window.tabs[t];
    title = tab.title();
    if (title.indexOf('appear.in') !== -1) {
      $.exit(100);
    }
  }
}

$.exit(0);
