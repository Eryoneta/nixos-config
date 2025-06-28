{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Klipper: Clipboard manager
  config.modules."plasma-klipper" = {
    tags = config.modules."plasma".tags;
    setup = {
      home = { # (Home-Manager Module)

        # Dotfile
        config.programs.plasma.configFile."klipperrc" = { # (plasma-manager option)
          "General" = {
            "IgnoreImages" = false; # Include images
            "KeepClipboardContents" = false; # Reset clipboard at every session
            "MaxClipItems" = 100; # Max items
          };
        };

      };
    };
  };

}
