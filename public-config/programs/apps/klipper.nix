{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Klipper: Clipboard manager
  config.modules."klipper" = {
    attr.packageChannel = pkgs-bundle.stable;# Not used (Included with KDE Plasma)
    tags = [ "default-setup" ];
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
