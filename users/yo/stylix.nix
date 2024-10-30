{ config, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Stylix: Themes and colors manager
    stylix = {
      enable = true;
      autoEnable = true; # Automatically set for installed apps

      # Wallpaper
      image = ( # Wallpaper
        pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"
      );
      imageScalingMode = "fill"; # Fill background

      # Theme
      polarity = "dark"; # Theme
      base16Scheme = with pkgs-bundle.stable; ( # Colors
        # Note: Between stable and unstable, some themes might not exist
        "${base16-schemes}/share/themes/oxocarbon-dark.yaml"
      );

      # Cursor
      cursor = {
        #package = "";
        #name = "";
        # TODO: (Yo/Stylix) Set custom cursor
        size = 24;
      };

      # Fonts
      fonts = {
        sizes = { # Font sizes
          applications = 10; 
          terminal = 10;
        };
      };

    };

  };
}
