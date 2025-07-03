{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Window Title: Plasmoid for Plasma, is a neat label that shows the title of the focused window
  config.modules."plasma-windowtitle" = {
    tags = config.modules."plasma".tags;
    attr.windowtitle-pkg = pkgs-bundle.windowtitle;
    attr.windowtitle = {
      name = "org.kde.windowtitle";
      config = {
        "Behavior" = {
          "closeAllowed" = false; # Do not close window (By middle click)
          "scrollAllowed" = false; # Do not scroll windows
          "showTooltip" = false; # Do not show tooltip (Redundant)
        };
      };
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.xdg.dataFile."plasma/plasmoids/org.kde.windowtitle" = {
          source = "${attr.windowtitle-pkg}";
        };

      };
    };
  };

}
