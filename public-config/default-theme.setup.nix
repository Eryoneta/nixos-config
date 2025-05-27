{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-theme" = {

    tags = [ "default-user" ];
    attr.packageChannel = args.pkgs-bundle.stable;

    setup = { attr }: {
      home = { # (Home-Manager Module)
        config = {

          # Stylix: Themes and colors manager
          stylix = {
            enable = true;
            autoEnable = (utils.mkDefault) true; # Automatically set for installed apps

            # Wallpaper
            image = (utils.mkDefault) ( # Wallpaper
              (args.pkgs-bundle.nixos-artwork)."wallpaper/nix-wallpaper-simple-blue.png"
            );
            imageScalingMode = (utils.mkDefault) "fill"; # Fill background

            # Cursor
            cursor = (utils.mkDefault) {
              package = (attr.packageChannel).bibata-cursors;
              name = "Bibata-Modern-Ice";
              size = 24;
            };

            # Fonts
            fonts = (utils.mkDefault) {
              emoji = {
                name = "Noto Color Emoji";
                package = (attr.packageChannel).noto-fonts-color-emoji;
              };
              monospace = {
                name = "Noto Sans Mono";
                package = (attr.packageChannel).noto-fonts;
              };
              sansSerif = {
                name = "Noto Sans";
                package = (attr.packageChannel).noto-fonts;
              };
              serif = {
                name = "Noto Serif";
                package = (attr.packageChannel).noto-fonts;
              };
              sizes = { # Font sizes
                applications = 10; # Apps UIs
                terminal = 10; # Terminals
                desktop = 10; # Window titles, bars, widgets, etc
                popups = 10; # Popups and notifications
              };
            };

            # Theme
            polarity = (utils.mkDefault) "light"; # Theme
            # Gallery: https://tinted-theming.github.io/base16-gallery/
            base16Scheme = (utils.mkDefault) (
              with attr.packageChannel; ( # Colors
                "${base16-schemes}/share/themes/nord-light.yaml"
                # Note: Between stable and unstable, some themes might not exist
              )
            );

          };

        };
      };
    };
  };
}
