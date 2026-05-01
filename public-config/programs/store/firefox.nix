{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Firefox: Internet browser
  config.modules."firefox" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.template = {
      extensions = with pkgs-bundle.firefox-addons.pkgs; [
        ublock-origin # UBlock-Origin: Adblocker
        plasma-integration # Plasma Integration: Integrates Plasma Desktop
      ];
      settings = {

        # UI (User Interface)
        "intl.locale.requested" = "pt-BR, en-US"; # UI language

        # UX (User experience)
        "browser.shell.checkDefaultBrowser" = false; # Do not check if the browser is the default
        "general.autoScroll" = true; # Enable autoscroll(Middle-click)
        "browser.tabs.warnOnClose" = true; # Warn before closing more than 1 tab
        "browser.tabs.maxOpenBeforeWarn" = 10; # Warn before opening too many bookmarks at once
        "browser.urlbar.suggest.calculator" = true; # Suggest results for math equations
        "browser.tabs.hoverPreview.enabled" = true; # Show a preview of the tab content on hover
        "extensions.autoDisableScopes" = 0; # Enable extensions by default
        # Updates
        "app.update.auto" = false; # Do not auto-update
        "app.update.service.enabled" = false; # Do not update on background
        "app.update.silent" = false; # Alert if an update happens
        "extensions.update.autoUpdateDefault" = false; # Do not auto-update by default
        # AI
        "browser.ai.control.default" = "blocked"; # Block all AI stuff
        "browser.ai.control.linkPreviewKeyPoints" = "blocked"; # Block preview when hovering an link
        "browser.ai.control.pdfjsAltText" = "blocked"; # Block PDF description
        "browser.ai.control.sidebarChatbot" = "blocked"; # Block chatbot icon at the sidebar
        "browser.ai.control.smartTabGroups" = "blocked"; # Block tab group suggestions
        "browser.ai.control.translations" = "blocked"; # Block AI translations

        # Privacy
        "permissions.default.geo" = 0; # Always ask
        "permissions.default.camera" = 0; # Always ask
        "permissions.default.microphone" = 0; # Always ask
        "permissions.default.desktop-notification" = 0; # Always ask

        # Security
        "network.IDN_show_punycode" = true; # Show real address characters

      };
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.firefox = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).firefox;

          # Languages
          languagePacks = [ "pt-BR" "en-US" ];

          # Policies
          # More at: "about:policies#documentaion"
          policies = {
            "DisableAppUpdate" = true; # Do not update
            "AppAutoUpdate" = false; # Do not auto-update
            "BackgroundAppUpdate" = false; # Do not update on background
            "DisableFirefoxAccounts" = true; # Disable user account("Firefox Sync")
            "DisableFirefoxStudies" = true; # Disable "Shield"
            "DisablePocket" = true; # Disable "Pocket"
            "DisableTelemetry" = true; # Disable telemetry
            "DontCheckDefaultBrowser" = true; # Do not check if the browser is the default
          };

          # Messaging Hosts
          nativeMessagingHosts = with attr.packageChannel; [
            kdePackages.plasma-browser-integration # Plasma Browser Integration
          ];

          # Default profile
          # This profile should be as "vanilla" as possible, the "new user experience"
          profiles."default" = {
            id = 0;
            isDefault = true;

            # Search engines
            search = {
              force = true;
              engines = {
                "google" = {
                  "metaData"."alias" = "@g";
                };
              };
              default = "google";
            };

            # Extensions
            extensions.packages = (utils.mkDefault) (attr.template).extensions;

            # Settings
            settings = (utils.mkDefault) (attr.template).settings;

          };

        };

        # Plasma Browser Integration: Integrate browsers into Plasma Desktop
        config.home.packages = with attr.packageChannel; [
          kdePackages.plasma-browser-integration
        ];

      };
    };
  };

  # Firefox: Internet browser
  config.modules."firefox.work" = {
    tags = [ "personal-setup" "work-setup" ];
    attr.template = {
      extensions = with (pkgs-bundle.firefox-addons).pkgs; (
        (config.modules."firefox".attr.template).extensions ++ [
          tab-stash # Tab Stash: Easily stash tabs inside a bookmark folder
        ]
      );
      settings = ((config.modules."firefox".attr.template).settings // {

        # UI (User Interface)
        "intl.accept_languages" = "pt-BR, pt, en-US, en"; # Priority of languages when accessing pages
        "layout.css.prefers-color-scheme.content-override" = 1; # Light theme
        "browser.toolbars.bookmarks.visibility" = "always"; # Always show bookmark-toolbar
        # User interface
        "browser.uiCustomization.state" = (
          let
            extensionCount = 3;
            # "Ublock-Origin" extension
            ublock-origin-id = "ublock0_raymondhill_net-browser-action";
            # "Tab Stash" extension
            tab-stash-id = "tab-stash_condordes_net-browser-action";
            # "Plasma Integration" extension
            plasma-integration-id = "plasma-browser-integration_kde_org-browser-action";
          in {
            "placements" = {
              "toolbar-menubar" = [ # The bar at the top(Alt)
                "menubar-items"
              ];
              "TabsToolbar" = [ # The bar that contains tabs
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
                plasma-integration-id
              ];
              "PersonalToolbar" = [ # The bar that contains bookmars
                "sidebar-button" # Sidebar button
                "customizableui-special-spring3"# Stretch space
                "personal-bookmarks" # Bookmarks
              ];
            };
            "seen" = [ # Stuff that are not included
              "save-to-pocket-button" # Pocket
              "profiler-button" # Profiler button
              "firefox-view-button" # Firefox View Button(Top-left)
            ];
            "dirtyAreaCache" = [ # All bars that were modified
              "nav-bar"
              "TabsToolbar"
              "PersonalToolbar"
              "toolbar-menubar"
              "unified-extensions-area"
            ];
            "currentVersion" = 20;
            "newElementCount" = 3 + extensionCount; # Springs + extensions
          }
        );
        # Theme
        "extensions.activeThemeID" = "dreamer-bold-colorway@mozilla.org"; # Purple theme!

        # UX (User experience)
        # Cookies
        "cookiebanners.ui.desktop.enabled" = true; # Enable cookie banner handling
        "cookiebanners.service.mode" = 1; # Reject all coookies or do nothing
        # Bookmarks
        "browser.bookmarks.openInTabClosesMenu" = false; # Open bookmark(Middle click), but don't close the menu
        "browser.tabs.loadBookmarksInBackground" = true; # Load open bookmark in background

        # Privacy
        "signon.rememberSignons" = false; # Do not ask to save passwords

      });
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Default profile
        config.programs.firefox.profiles."default" = {

          # Extensions
          extensions.packages = (attr.template).extensions;

          # Settings
          settings = (attr.template).settings;

        };

      };
    };
  };

}
