{ ... }@args: with args.config-utils; {
  config = {

    # Stylix: Themes and colors manager
    stylix = {

      # Wallpaper
      # image = ""; # Wallpaper
      # imageScallingMode = "fill";
      # TODO: (Yo/Stylix) Set a wallpaper

      # Theme
      polarity = "dark"; # Theme
      base16Scheme = with pkgs-bundle.stable; ( # Colors
        "${base16-schemes}/share/themes/moonlight.yaml"
      );

      # Cursor
      # cursor = {
      #   package = "";
      #   name = "";
      #   size = 24;
      # };
      # TODO: (Yo/Stylix) Set a cursor

    };

  };
}
