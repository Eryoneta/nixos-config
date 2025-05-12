{ config, lib, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; (lib.mkIf (options.enabled) {

    # KWin Window manager for Plasma
    programs.plasma.kwin = { # (plasma-manager option)

      # Virtual desktops
      virtualDesktops.names = [ # List of virtual desktops
        "Primary Desktop"
        "Auxiliary Desktop"
        "Extra Desktop"
        "Emergency Desktop"
      ];

    };

    # Activities
    profile.programs.plasma = {
      options.activities = rec {
        list = { # Note: It's alfabetically ordered
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
      };

    };

  });
}
