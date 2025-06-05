{ ... }@args: with args.config-utils; { # (Setup Module)

  # Desktop entries
  config.modules."desktop-entries" = {
    tags = [ "default-setup" ];
    setup = {
      home = { # (Home-Manager Module)

        # XDG Desktop Entries
        config.xdg = {
          desktopEntries = {
            "nixos-manual" = { # Hide "NixOS Manual" entry
              name = "NixOS Manual";
              exec = "nixos-help";
              noDisplay = true;
            };
          };
        };

      };
    };
  };

}
