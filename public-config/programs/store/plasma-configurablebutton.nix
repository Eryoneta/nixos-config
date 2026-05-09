{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Window Title: Plasmoid for Plasma, is a neat label that shows the title of the focused window
  config.modules."plasma-configurablebutton" = rec {
    tags = config.modules."plasma".tags;
    attr.configurablebutton-pkg = pkgs-bundle.configurablebutton;
    attr.mkButton = icon: action: {
      name = "com.github.configurable_button";
      config = {
        "General" = {
          "iconOff" = icon;
          "iconOn" = icon;
          "offScript" = action;
          "onScript" = action;
        };
      };
    };
    attr.configurablebutton = {
      showGrid = (attr.mkButton "show-grid-symbolic" "qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut 'Grid View'");
      toggleYakuake = (attr.mkButton "yakuake-symbolic" "yakuake");
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.xdg.dataFile."plasma/plasmoids/com.github.configurable_button" = {
          source = "${attr.configurablebutton-pkg}";
        };

      };
    };
  };

}
