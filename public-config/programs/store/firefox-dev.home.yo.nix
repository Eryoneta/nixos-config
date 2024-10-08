{ config, pkgs-bundle, user, pkgs, ... }@args: with args.config-utils; {
  config = {

    # Firefox Developer Edition: Browser
    # Can be used alonside regular "Firefox"
    # But! There is potential for a conflict between the two!
    #   Here, "firefox" is using "pkgs-bundle.stable"
    #   And "firefox-devedition" is using "pkgs-bundle.unstable"
    #   Pray that the two packages are "far away" from eachother(Different versions)
    #   If not, there is a conflict and the rebuild fails
    # TODO: Fix? How?

    # Note: Added with override below (With FX-AutoConfig)
    #home.packages = with pkgs-bundle.unstable; [ firefox-devedition ];

    # The profiles configuration are shared with regular "Firefox" (Convenient!)
    programs.firefox = {

      # Personal profile
      # This profile is personal. Customization without limits!
      profiles."dev-edition-default" = {
        # It NEEDS to be "dev-edition-default"!
        #   This way "firefox-devedition" doesn't complain about "missing profiles"
        #   If it doesn't find it, then it creates a new one, but it can't edit "profiles.ini", throws an error
        id = 1;
        #name = "Yo"; # HAS to be "dev-edition-default"
        isDefault = false;  # Only one can be the default

        # Search engines
        search = {
          force = true;
          engines = {
            "Google" = {
              metaData.alias = "@g";
            };
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    { name = "type"; value = "packages"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://wiki.nixos.org/index.php?search={searchTerms}";
                }
              ];
              iconUpdateURL = "https://wiki.nixos.org/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # Every day
              definedAlias = [ "@nw" ];
            };
          };
          default = "Google"; # For now
          order = [
            "Google" # TODO: Change?
            "DuckDuckGo"
          ];
        };

        # Extensions
        extensions = (
          config.programs.firefox.profiles."template-profile".extensions
          ++
          (with pkgs-bundle.firefox-addons; [
            tab-stash # Tab Stash: Easily stash tabs inside a bookmark folder
            sidebery # Sidebery: Sidebar with vertical tabs
          ])
        );

        # Settings
        settings = (config.programs.firefox.profiles."template-profile".settings // {

          # UI (User Interface)
          #"toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Can change UI with a css file
          "browser.toolbars.bookmarks.visibility" = "always"; # Always show bookmark-toolbar
          "browser.compactmode.show" = true; # Allows to use compact-view
          "browser.uidensity" = 1; # Use compact-view
          "media.videocontrols.picture-in-picture-video-toggle-enable" = true; # Picture-In-Picture
          # Theme
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org"; # Dark theme!
          # New page
          "browser.newtabpage.activity-stream.showWeather" = false; # Do not show weather info
          "browser.newtabpage.activity-stream.feeds.topsites" = false; # Do not show grid of sites
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # Do not show stories
          # Tabs
          "browser.tabs.tabMinWidth" = 32; # Tab minimum size
          "browser.tabs.tabClipWidth" = 64; # Tab minimum size before hiding details
          # Icons actions at URLbar
          "browser.pageActions.persistedActions" = (
            let
              # "Tab Stash" extension
              tab-stash-id = "tab-stash_condordes_net";
              # "Sidebery" extension
              sidebery-id = "_3c078156-979c-498b-8990-85f7987dd929_";
            in {
              "ids" = [ # Lists ids of icons
                "bookmark" # Bookmark star
                tab-stash-id
                sidebery-id
              ];
              "idsInUrlbar" = [ # Lists icons in the URLbar
                "bookmark"
                #tab-stash-id # NOT included in the bar!
                #sidebery-id # Not included in the bar
                # ...But it doesn't work. Both are still included
              ];
              "idsInUrlbarPreProton" = [];
              "version" = 1;
            }
          );
          # User interface
          "browser.uiCustomization.state" = (
            let
              # "Ublock-Origin" extension
              ublock-origin-id = "ublock0_raymondhill_net-browser-action";
              # "Tab Stash" extension
              tab-stash-id = "tab-stash_condordes_net-browser-action";
              # "Sidebery" extension
              sidebery-id = "_3c078156-979c-498b-8990-85f7987dd929_-browser-action";
            in {
              "placements" = {
                "toolbar-menubar" = [ # The bar at the top(Alt)
                  "menubar-items"
                ];
                "TabsToolbar" = [ # The bar that contains tabs
                  "firefox-view-button" # Firefox View Button(Top-left)
                  "alltabs-button" # All-tabs button
                  "tabbrowser-tabs" # Tabs
                  "new-tab-button" # New-tab button
                ];
                "nav-bar" = [ # The bar that contains URLbar
                  "back-button" # Go-back button
                  "forward-button" # Go-forward button
                  "stop-reload-button" # Reload button
                  "customizableui-special-spring1" # Stretch space
                  tab-stash-id
                  "urlbar-container" # URLbar
                  "customizableui-special-spring2" # Stretch space
                  "downloads-button" # Downloads button
                  "developer-button" # Developer tools button
                  "history-panelmenu" # History button
                  "unified-extensions-button" # Extensions button
                ];
                "widget-overflow-fixed-list" = [];
                "unified-extensions-area" = [ # List of extensions not in the bars
                  ublock-origin-id
                ];
                "PersonalToolbar" = [ # The bar that contains bookmars
                  "sidebar-button" # Sidebar button
                  sidebery-id
                  "customizableui-special-spring3"# Stretch space
                  "personal-bookmarks" # Bookmarks
                ];
              };
              "seen" = [ # Stuff that are not included
                "save-to-pocket-button" # Pocket
                "profiler-button" # Profiler button
              ];
              "dirtyAreaCache" = [ # All bars that were modified
                "nav-bar"
                "TabsToolbar"
                "PersonalToolbar"
                "toolbar-menubar"
                "unified-extensions-area"
              ];
              "currentVersion" = 20;
              "newElementCount" = 3 + 3; # Springs + extensions
            }
          );

          # UX (User experience)
          "browser.aboutConfig.showWarning" = false; # Do not warn at "about:config"
          "media.autoplay.default" = 5; # Do not autoplay videos
          "browser.download.useDownloadDir" = false; # Do not immediately download, ask first
          # Cookies
          "cookiebanners.ui.desktop.enabled" = true; # Enable cookie banner handling
          "cookiebanners.service.mode" = 1; # Reject all coookies or do nothing
          # Delays
          "ui.tooltipDelay" = 100; # Decrease tooltip delay
          "ui.submenuDelay" = 300; # Decrease submenu delay
          # Bookmarks
          "browser.bookmarks.editDialog.maxRecentFolders" = 10; # Maximum amount of folders shown in "Edit Bookmark"
          "browser.bookmarks.openInTabClosesMenu" = false; # Open bookmark(Middle click), but don't close the menu
          "browser.tabs.loadBookmarksInBackground" = true; # Load open bookmark in background
          # Fullscreen popup
          "full-screen-api.warning.delay" = 0; # No delay before triggering the exit popup
          "full-screen-api.transition-duration.enter" = "0 0"; # No delay before entering
          "full-screen-api.transition-duration.leave" = "0 0"; # No delay before exiting
          # Audio
          "media.audio.playbackrate.muting_threshold" = 16; # Mute audio only at speeds above x16
          "media.audio.playbackrate.soundtouch_seekwindow_ms" = 15; # Time-window for the algorithm to find points to cut the audio
          "media.audio.playbackrate.soundtouch_sequence_ms" = 25; # How much the original audio can be cut
          "media.audio.playbackrate.soundtouch_overlap_ms" = 28; # How much overlap can happen between the cut audios
          # URLbar
          "browser.urlbar.trimHttps" = false; # Do not trim "https://"
          "browser.urlbar.autoFill" = false; # Do not auto-complete urls
          "browser.urlbar.quicksuggest.enabled" = false; # Do not suggest stuff
          "browser.search.suggest.enabled" = false; # Do not suggest search stuff
          "browser.urlbar.suggest.searches" = false; # Do not suggest searches
          # Unwanted stuff
          "extensions.pocket.enabled" = false; # Disable "Pocket"
          "browser.discovery.enabled" = false; # Do not recommend extensions
          "browser.preferences.moreFromMozilla" = false; # Do not show "More from Mozilla" at configurations
          "browser.aboutwelcome.enabled" = false; # Do not show the  welcome page
          "identity.fxaccounts.enabled" = false; # Disable user account("Firefox Sync')
          "identity.fxaccounts.toolbar.enabled" = false; # Remove login in hamburger menu

          # Privacy
          "dom.battery.enabled" = false; # Do not inform about battery status
          "dom.event.clipboardevents.enabled" = false; # Do not notify sites about copy, cut, and paste
          "browser.tabs.searchclipboardfor.middleclick" = false; # Do not search using clipboard
          "browser.formfill.enable" = false; # Do not fill forms
          "signon.rememberSignons" = false; # Do not ask to save passwords
          "dom.private-attribution.submission.enabled" = false; # Do not inform measurements to advertisers
          "privacy.firstparty.isolate" = true; # Isolate cookies to its own domain
          "privacy.resistFingerprinting" = true; # Resist browser fingerprinting
          # Cookies
          "network.cookie.cookieBehavior" = 1; # Block third party cookies
          "network.cookie.lifetimePolicy" = 2; # Delete cookies at the end of the session
          # Containers
          "privacy.userContext.enabled" = true; # Enable "Containers"
          # Clear everything on close
          "privacy.sanitize.sanitizeOnShutdown" = true; # Clear stuff on close
          "privacy.sanitize.timeSpan" = 0; # Clear everything, not just recents
          "privacy.clearOnShutdown.cache" = true; # Clear cache on close
          "privacy.clearOnShutdown.cookies" = true; # Clear cookies on close
          "privacy.clearOnShutdown.downloads" = true; # Clear listed downloads on close
          "privacy.clearOnShutdown.formData" = true; # Clear form fills on close
          "privacy.clearOnShutdown.history" = true; # Clear history on close
          "privacy.clearOnShutdown.offlineApps" = true; # Clear local web data on close
          "privacy.clearOnShutdown.sessions" = true; # Clear logins on close
          "privacy.clearOnShutdown.siteSettings" = true; # Clear site settings on close
          # Disable studies
          "app.shield.optoutstudies.enabled" = false; # Disable "Shield"
          "app.normandy.enabled" = false; # Disable "Normandy"
          "app.normandy.api_url" = ""; # Do not send "Normandy" data
          # Disable crash reports
          "breakpad.reportURL" = ""; # Do not send crash reports
          "browser.tabs.crashReporting.sendReport" = false; # Do not report tabs crashes
          "browser.crashReports.unsubmittedCheck.enabled" = false; # Do not complain about unsent reports
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # Do not send crash reports
          "datareporting.healthreport.uploadEnabled" = false; # Do not report heath
          "datareporting.policy.dataSubmissionEnabled" = false; # Do not submit report
          # Disable all telemetry
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.telemetry.pioneer-new-studies-available" = false;
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";
          "browser.ping-centre.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;

        });

      };
      
    };

    # FX-AutoConfig: Custom JavaScript loader
    home = (
      let
        fx-autoconfig = pkgs-bundle.fx-autoconfig;
        profilePath = ".mozilla/firefox/dev-edition-default";
      in {
        packages = with pkgs-bundle.unstable; [
          (firefox-devedition.override {
            extraPrefsFiles = [
              # Enable "userChromeJS"
              "${fx-autoconfig}/program/config.js"
            ];
          })
        ];
        # Load scripts and styles
        file."${profilePath}/chrome/utils" = {
          source = "${fx-autoconfig}/profile/chrome/utils";
        };
        # Small example
        file."${profilePath}/chrome/CSS/small_dot_example.uc.css" = {
          source = "${fx-autoconfig}/profile/chrome/CSS/author_style.uc.css";
        };
        # TODO: Add my firefox scripts and styles
      }
    );

  };

}
