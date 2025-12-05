{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # KWin: Window manager for Plasma
  config.modules."plasma-kwin.personal" = {
    tags = config.modules."plasma.personal".tags;
    attr.activities = config.modules."plasma-kwin".attr.activities;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.kwin = { # (plasma-manager option)

          # Dotfile: Virtual desktops
          virtualDesktops.names = [ # List of virtual desktops
            "Primary Desktop"
            "Auxiliary Desktop"
            "Extra Desktop"
          ];

        };

        # Dotfile: Activities
        # Note: Old activities are not removed
        config.programs.plasma.configFile."kactivitymanagerdrc" = ( # (plasma-manager option)
          attr.activities rec {
            list = { # Note: The final result is alfabetically ordered
              "personal" = {
                id = "personal-activity";
                name = "Personal Activity";
                icon = "nix-snowflake-white";
              };
              "public" = {
                id = "public-activity";
                name = "Public Activity";
                icon = "avatar-default-symbolic";
              };
            };
            startId = list."personal".id;
          }
        );

      };
    };
  };

}
