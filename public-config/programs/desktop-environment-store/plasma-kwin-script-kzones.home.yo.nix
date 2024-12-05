{ lib, config, config-domain, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; (lib.mkIf (options.enabled) {

    # KZones: KWin script for snapping windows into zones
    home.packages = with options.packageChannel; [
      (kdePackages.kzones.override {
        # Hack incoming: Replace proper package download with my own package in "dotfiles"
        # It is a newer version
        fetchFromGitHub = ignoredArgs: (
          "${config-domain.public.dotfiles}/kwin"
        );
      })
      #kdePackages.kzones
      # TODO: (Plasma/KWin/KZones) Remove hack once v0.10 is available
    ];

    # Configuration
    programs.plasma.configFile."kwinrc" = { # (plasma-manager option)
      "Plugins" = {
        "kzonesEnabled" = true; # Enables KZones
      };
      "Windows" = {
        "ElectricBorderMaximize" = false; # Disable maximize when dragging into the top border
        "ElectricBorderTiling" = false; # Disable window tiling
      };
      "Script-kzones" = {
        "enableEdgeSnapping" = true; # Snap windows when dragged to edges
        "edgeSnappingTriggerDistance" = 0; # Trigger snap only when at the very edge
        "zoneOverlayIndicatorDisplay" = 1; # Show zone indicators
        "zoneSelectorTriggerDistance" = 0; # Show zone selector(Top menu) only when at the very top edge
        "layoutsJson" = "[${
          utils.toJSON {
            "name" = "Quadrant Grid";
            "padding" = 0;
            "zones" = [
              {
                "x" = 0;
                "y" = 0;
                "height" = 50;
                "width" = 100;
                "indicator" = {
                  "position" = "top-center";
                };
              }
              {
                "x" = 0;
                "y" = 50;
                "height" = 50;
                "width" = 100;
                "indicator" = {
                  "position" = "bottom-center";
                };
              }
              {
                "x" = 0;
                "y" = 0;
                "height" = 100;
                "width" = 100;
                "indicator" = {
                  "position" = "center";
                };
              }
              {
                "x" = 0;
                "y" = 0.01;
                "height" = 50;
                "width" = 50;
                "indicator" = {
                  "position" = "top-left";
                };
              }
              {
                "x" = 50;
                "y" = 0.01;
                "height" = 50;
                "width" = 50;
                "indicator" = {
                  "position" = "top-right";
                };
              }
              {
                "x" = 0;
                "y" = 50;
                "height" = 50;
                "width" = 50;
                "indicator" = {
                  "position" = "bottom-left";
                };
              }
              {
                "x" = 50;
                "y" = 50;
                "height" = 50;
                "width" = 50;
                "indicator" = {
                  "position" = "bottom-right";
                };
              }
              {
                "x" = 0;
                "y" = 0.01;
                "height" = 100;
                "width" = 50;
                "indicator" = {
                  "position" = "left-center";
                };
              }
              {
                "x" = 50;
                "y" = 0.01;
                "height" = 100;
                "width" = 50;
                "indicator" = {
                  "position" = "right-center";
                };
              }
            ];
          }
        }]";
      };
    };

  });

}
