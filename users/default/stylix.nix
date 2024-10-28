{ config, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Stylix: Themes and colors manager
    stylix = {
      enable = (utils.mkDefault) true;
      autoEnable = (utils.mkDefault) true; # Automatically set for installed apps

      # Wallpaper
      image = (utils.mkDefault) ( # Wallpaper
        pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"
      );
      imageScallingMode = (utils.mkDefault) "fill";

      # Theme
      polarity = (utils.mkDefault) "light"; # Theme

    };

  };
}
