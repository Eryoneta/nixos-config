{ pkgs-bundle, pkgs, ... }@args: with args.config-utils; {
  config = {

    # Firefox Developer Edition: Browser
    # Can be used alonside regular "Firefox"
    # But! There is potential for a conflict between the two!
    #   Here, "firefox" is using "pkgs-bundle.stable"
    #   And "firefox-devedition" is using "pkgs-bundle.unstable"
    #   Pray that the two packages are "far away" from eachother(Different versions)
    #   If not, there is a conflict and the rebuild fails
    # TODO: Fix? How?
    home.packages = with pkgs-bundle.unstable; [ firefox-devedition ];

    # The profiles configuration are shared with regular "Firefox" (Convenient!)
    programs.firefox = {

      # Personal profile
      # It NEEDS to be "dev-edition-default"!
      #   This way "firefox-devedition" doesn't complain about "missing profiles"
      #   If it doesn't find it, then it creates a new one, but it can't edit "profiles.ini"
      profiles.dev-edition-default = {
        id = 1;
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

        # Settings
        settings = {};

        # Extensions
        extensions = [];

      };

      # Policies
      policies = {};
      
    };

  };

}
