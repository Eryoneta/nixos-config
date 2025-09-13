{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Fonts
  config.modules."fonts" = {
    tags = [ "default-setup" ];
    setup = {
      nixos = { pkgs, ... }: { # (NixOS Module)

        # Fonts
        config.fonts = {
          enableDefaultPackages = true; # Include default fonts

          # Installed fonts
          packages = with pkgs; [
            corefonts # Microsoft fonts for websites(Includes "Comic Sans MS"! Yay!)
            vistafonts # More fonts from Microsoft
            liberation_ttf # Liberation fonts, equivalent for "Times New Roman", "Arial", and "Courier New"
            noto-fonts # Font for many languages
            noto-fonts-color-emoji # Emoji font
            symbola # Emoji font
            #comic-relief # "Comic Sans MS" equivalent
            nerd-fonts.envy-code-r # Programming font
            nerd-fonts.comic-shanns-mono # Like "Comic Sans MS", but monosized
            nerd-fonts.roboto-mono # Programming font
            nerd-fonts.meslo-lg # Programming font
          ];

          # Font configurations
          fontconfig = {
            enable = true; # Configure fonts
            antialias = true; # Smooth font
            subpixel = {
              rgba = (utils.mkDefault) "rgb"; # Subpixel order of the screen
            };
            hinting = {
              enable = true; # Enable sharper fonts
              style = (utils.mkDefault) "full"; # Font sharpness
            };
          };

          # Note:
          #   New fonts can be placed at "$XDG_DATA_HOME/fonts"
          #   "fc-cache -f -v" reloads the font cache

        };

      };
    };
  };

}
