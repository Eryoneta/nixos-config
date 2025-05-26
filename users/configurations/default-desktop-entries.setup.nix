{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-desktop-entries" = {

    tags = [ "default-user" ];

    setup = {
      home = { # (Home-Manager Module)
        config = {

          # XDG Desktop Entries
          xdg = {
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
  };
}
