{ pkgs, ... }@args: with args.config-utils; {
  config = {

    fonts = {
      enableDefaultPackages = true; # Include default fonts
      packages = with pkgs; [
        corefonts # Microsoft fonts for websites(Includes "Comic Sans MS"! Yay!)
        vistafonts # More fonts from Microsoft
        liberation_ttf # Liberation fonts, equivalent for "Times New Roman", "Arial", and "Courier New"
        noto-fonts # Font for many languages
        noto-fonts-color-emoji # Emoji font
        symbola # Emoji font
        #comic-relief # "Comic Sans MS" equivalent
        (nerdfonts.override {
          # List: https://www.nerdfonts.com/font-downloads
          fonts = [
            "ComicShannsMono" # Like "Comic Sans MS", but monosized
            "Meslo" # Programming font
            "RobotoMono" # Programming font
          ];
        })
      ];
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
    };

  };
}
