
// PDF profile: no sidebar, no session restore (tabs and toolbars are hidden by pdf-userChrome.css)
user_pref("sidebar.revamp", false);
user_pref("sidebar.verticalTabs", false);
user_pref("browser.startup.page", 1);
user_pref("browser.sessionstore.resume_from_crash", false);
// Local files need no disk cache
user_pref("browser.cache.disk.enable", false);
