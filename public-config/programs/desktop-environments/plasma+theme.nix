{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Plasma: A Desktop Environment focused on customization
  config.modules."plasma+theme" = {
    tags = config.modules."plasma".tags;
    attr.applyTheme = false; # The theme is managed by Stylix
    attr.nixos-artwork = pkgs-bundle.nixos-artwork;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Theme
        config.programs.plasma.workspace = { # (plasma-manager option)

          # Cursor
          cursor = {
            theme = (utils.mkIf (attr.applyTheme) (
              (utils.mkDefault) "Breeze" # Cursor theme
            ));
            size = (utils.mkIf (attr.applyTheme) (
              (utils.mkDefault) 32 # Cursor size
            ));
          };

          # Wallpaper
          wallpaper = (utils.mkIf (attr.applyTheme) (
            (utils.mkDefault) ( # Wallpaper
              attr.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"
            )
          ));
          wallpaperFillMode = (utils.mkIf (attr.applyTheme) (
            (utils.mkDefault) "preserveAspectCrop" # Resize and cut excess
          ));

          # Themes
          theme = (utils.mkIf (attr.applyTheme) (
            (utils.mkDefault) "breeze-dark" # Global Theme
            # Run "plasma-apply-desktoptheme --list-themes" for options
          ));
          lookAndFeel = (utils.mkIf (attr.applyTheme) (
            (utils.mkDefault) "org.kde.breezedark.desktop" # Theme
            # Run "plasma-apply-lookandfeel --list" for options
          ));
          colorScheme = (utils.mkIf (attr.applyTheme) (
            (utils.mkDefault) "BreezeDark" # Color theme
            # Run "plasma-apply-colorscheme --list-schemes" for options
          ));
          iconTheme = (utils.mkIf (attr.applyTheme) (
            (utils.mkDefault) "Breeze-Dark" # Icons theme
          ));
          soundTheme = (utils.mkIf (attr.applyTheme) (
            (utils.mkDefault) "Ocean" # Sound theme
          ));

        };

      };
    };
  };

}
