{ config, lib, ... }@args: with args.config-utils; {
  config = with config.profile.programs.firefox; (lib.mkIf (options.enabled) {

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
              "metaData"."alias" = "@g";
            };
          };
          default = "Google";
        };

        # Extensions
        extensions = (
          config.programs.firefox.profiles."template-profile".extensions
          ++
          (with args.pkgs-bundle.firefox-addons.pkgs; [
            tab-stash # Tab Stash: Easily stash tabs inside a bookmark folder
          ])
        );

        # Settings
        settings = (config.programs.firefox.profiles."template-profile".settings // (
          options.defaults."settings"
        ));

      };

    };

    profile.programs.firefox = { # Load settings into my "firefox.options.defaults"
      options.defaults = {
        "settings" = (import ./firefox+settings.nix);
      };
    };

  });
}
