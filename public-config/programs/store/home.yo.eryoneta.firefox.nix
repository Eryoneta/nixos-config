{ config, pkgs-bundle, user, ... }@args: with args.config-utils; {
  config = {

    # Firefox: Browser
    programs.firefox = {

      # Public profile
      # This profile should be as "vanilla" as possible, the "new user experience"
      profiles."default" = {
        id = 0;
        #name = "Eryoneta"; # HAS to be "default"
        isDefault = true;

        # Search engines
        search = {
          force = true;
          engines = {
            "Google" = {
              metaData.alias = "@g";
            };
          };
          default = "Google";
        };

        # Extensions
        extensions = (
          config.programs.firefox.profiles."template-profile".extensions
          ++
          (with pkgs-bundle.firefox-addons.packages.${user.host.system.architecture}; [
            tab-stash # Tab Stash: Easily stash tabs inside a bookmark folder
          ])
        );

        # Settings
        settings = (config.programs.firefox.profiles."template-profile".settings // {

          # UI (User Interface)
          "browser.toolbars.bookmarks.visibility" = "always"; # Always show bookmark-toolbar
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
      
    };
  };
}
