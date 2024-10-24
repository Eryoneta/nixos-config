{ config, pkgs-bundle, pkgs, ... }@args: with args.config-utils; {

  options = {
    profile.programs.firefox-devedition = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.unstable);
      options.defaults = (utils.mkDefaultsOption {
        settings = (import ./firefox-dev+settings.nix);
      });
    };
  };

  config = with config.profile.programs.firefox-devedition; {

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
      profiles."dev-edition-default" = utils.mkIf (options.enabled) {
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
                  template = "https://nixos.wiki/index.php?search={searchTerms}";
                }
              ];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # Every day
              definedAlias = [ "@nw" ];
            };
          };
          default = "DuckDuckGo"; # Is more reliable than Google
          order = [
            "DuckDuckGo"
            "Google"
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
        settings = (config.programs.firefox.profiles."template-profile".settings // (
          options.defaults.settings
        ));

      };
      
    };

    # FX-AutoConfig: Custom JavaScript loader
    home = (
      let
        fx-autoconfig = pkgs-bundle.fx-autoconfig;
        profilePath = ".mozilla/firefox/dev-edition-default";
      in {

        # Firefox Developer Edition: Browser
        packages = utils.mkIf (options.enabled) (
          with options.packageChannel; [
            (firefox-devedition.override {
              extraPrefsFiles = [
                # Enable "userChromeJS"
                "${fx-autoconfig}/program/config.js"
              ];
            })
          ]
        );

        # Dotfile: Load scripts and styles
        file."${profilePath}/chrome/utils" = {
          enable = options.enabled;
          source = "${fx-autoconfig}/profile/chrome/utils";
        };

        # Dotfile: Small example
        file."${profilePath}/chrome/CSS/small_dot_example.uc.css" = {
          enable = options.enabled;
          source = "${fx-autoconfig}/profile/chrome/CSS/author_style.uc.css";
        };
        
        # TODO: Add my firefox scripts and styles

      }
    );

  };

}
