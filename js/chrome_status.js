ObjC.import('stdlib')

try {
  var chrome = Application('Google Chrome');

  var window, w, tab, t, title, url;

  for (w = 0; w < chrome.windows.length; w++) {
    window = chrome.windows[w];
    for (t = 0; t < window.tabs.length; t++) {
      tab = window.tabs[i];
      title = tab.title();
      if (title.indexOf('appear.in') !== -1) {
        $.exit(100);
      }
    }
  }

} catch(e) {
  // Chrome isn't running.
  $.exit(0);
}


$.exit(0);
