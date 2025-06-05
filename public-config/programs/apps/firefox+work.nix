{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Firefox: Internet browser
  config.modules."firefox+work" = {
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
          extensions = (attr.template).extensions;

          # Settings
          settings = (attr.template).settings;

        };

      };
    };
  };

}
