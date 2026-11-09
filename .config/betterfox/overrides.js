// MY OVERRIDES
user_pref("network.trr.mode", 5);
user_pref("signon.rememberSignons", false);
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);
// Open previous windows and tabs
user_pref("browser.startup.page", 3);
// Translations run on this computer; no popup, the icon in the address bar stays
user_pref("browser.translations.automaticallyPopup", false);
// Extensions placed by firefox-profiles start enabled
user_pref("extensions.autoDisableScopes", 0);

// SPEED
// Disk cache on (Betterfox turns it off): repeat visits and restarts load faster
user_pref("browser.cache.disk.enable", true);
user_pref("network.http.pacing.requests.enabled", false);
// Pinned tabs load when first selected, like the others
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);

// SECURITY
// Installed CAs can't override certificate pins
user_pref("security.cert_pinning.enforcement_level", 2);
// WebRTC uses only the default network interface
user_pref("media.peerconnection.ice.default_address_only", true);
// No page screenshots in the profile
user_pref("browser.pagethumbnails.capturing_disabled", true);

// SMOOTHFOX: Zen smooth scrolling (120 Hz+)
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.currentVelocityWeighting", "0.15");
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6");
user_pref("mousewheel.min_line_scroll_amount", 10);
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 80);
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
user_pref("mousewheel.default.delta_multiplier_y", 200);

// VERTICAL TABS ON THE RIGHT
user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);
user_pref("sidebar.position_start", false);
