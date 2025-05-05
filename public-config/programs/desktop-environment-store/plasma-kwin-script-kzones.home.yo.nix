{ lib, config, config-domain, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; (lib.mkIf (false) {

    # KZones: KWin script for snapping windows into zones
    home.packages = with options.packageChannel; [
      (kdePackages.kzones.override {
        # Hack incoming: Replace proper package download with my own package in "dotfiles"
        # It is a newer, modified version
        #   (Zones indicators have priority over edges)
        fetchFromGitHub = ignoredArgs: (
          "${config-domain.public.dotfiles}/kwin/kzones"
        );
      })
      #kdePackages.kzones
      # TODO: (Plasma/KWin/KZones) Remove hack once v0.10 is available?
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
        "enableZoneSelector" = false; # Disable zone selector(Top menu)
        #"zoneSelectorTriggerDistance" = 0; # Show zone selector(Top menu) only when at the very top edge
        "layoutsJson" = "[${
          utils.toJSON {
            "name" = "Quadrant Grid"; # Label
            "padding" = 0; # No space between zones
            "zones" = (
              let

                # Utils
                screen = {
                  area = { # Area of the screen to be zoned, in %
                    "x" = 0;
                    "y" = 0;
                    "width" = 100;
                    "height" = 100;
                  };
                  hotEdges = [];
                };
                tinyVerticalSpace = 0.01; # In %, should be a space so tiny, only the mouse picks it up
                tinyHorizontalSpace = 0.005; # In %, should be a space so tiny, only the mouse picks it up
                mkArea = (area: margins: ( # Gets an area and returns it with margins added
                  let
                    addVerticalMargin = margin: ( # If the margin required is listed, returns the space to be added
                      if (builtins.elem margin margins) then tinyVerticalSpace else 0
                    );
                    addHorizontalMargin = margin: ( # If the margin required is listed, returns the space to be added
                      if (builtins.elem margin margins) then tinyHorizontalSpace else 0
                    );
                  in {
                    "x" = area."x" + (addHorizontalMargin "left");
                    "y" = area."y" + (addVerticalMargin "top");
                    "width" = area."width" - (addHorizontalMargin "left") - (addHorizontalMargin "right");
                    "height" = area."height" - (addVerticalMargin "top") - (addVerticalMargin "bottom");
                  }
                ));
                indicatorMargin = { # In px, distance to move the zone indicators
                  vertical = -50;
                  horizontal = -80;
                };
                mkIndicatorMargins = indicatorPosition: ( # Adds a margin to each zone indicator
                  let
                    addMargin = position: positions: (
                      if (builtins.elem position positions) then (
                        orientationMargins.${position}
                      ) else 0
                    );
                    orientationMargins = {
                      "top" = indicatorMargin.vertical;
                      "bottom" = indicatorMargin.vertical;
                      "left" = indicatorMargin.horizontal;
                      "right" = indicatorMargin.horizontal;
                    };
                    margins = {
                      "center" = [];
                      "top-left" = [ "top" "left" ];
                      "top-center" = [ "top" ];
                      "top-right" = [ "top" "right" ];
                      "right-center" = [ "right" ];
                      "bottom-right" = [ "bottom" "right" ];
                      "bottom-center" = [ "bottom" ];
                      "bottom-left" = [ "bottom" "left" ];
                      "left-center" = [ "left" ];
                    };
                  in {
                    "top" = (addMargin "top" margins.${indicatorPosition});
                    "bottom" = (addMargin "bottom" margins.${indicatorPosition});
                    "left" = (addMargin "left" margins.${indicatorPosition});
                    "right" = (addMargin "right" margins.${indicatorPosition});
                  }
                );
                mkInvisibleIndicator = { # Sets the indicator to be outside the screen
                  "position" = "bottom-center";
                  "margin" = {
                    "top" = 0;
                    "bottom" = -100; # Out of screen
                    "left" = 0;
                    "right" = 0;
                  };
                };
                # Originally, indicators are BEHIND hotEdges. Here, moving them doesn't really change anything
                #   But! My modified "kzones.kwinscript" prioritizes indicators over hotEdges!
                #   The indicators can be used to easily put windows into corners!
                mkZone = (area: indicatorPosition: { # Create a kzone
                  "x" = area."x";
                  "y" = area."y";
                  "width" = area."width";
                  "height" = area."height";
                  "indicator" = (
                    if (indicatorPosition == "none") then
                      mkInvisibleIndicator
                    else {
                      "position" = indicatorPosition;
                      "margin" = (mkIndicatorMargins indicatorPosition);
                    }
                  );
                });

                # Zone makers
                #   Each one gets a parent and edges which should activate it
                #   The parent defines the area
                #   The parents hotEdges defines a little space to be left, allowing dragging into the parent zone
                mkNoSplit = parentZone: hotEdges: (
                  let
                    area = (mkArea parentZone.area parentZone.hotEdges);
                  in { # 1 Zone
                    inherit area hotEdges;
                    full = (mkZone area "none");
                  }
                );
                mkVerticalSplit = parentZone: hotEdges: (
                  let
                    area = (mkArea parentZone.area parentZone.hotEdges);
                  in { # 2 vertical zones
                    inherit area hotEdges;
                    top = (mkZone {
                      "x" = area."x";
                      "y" = area."y";
                      "width" = area."width";
                      "height" = area."height" / 2;
                    } "top-center");
                    bottom = (mkZone {
                      "x" = area."x";
                      "y" = area."y" + (area."height" / 2);
                      "width" = area."width";
                      "height" = area."height" / 2;
                    } "bottom-center");
                  }
                );
                mkHorizontalSplit = parentZone: hotEdges: (
                  let
                    area = (mkArea parentZone.area parentZone.hotEdges);
                  in { # 2 horizontal zones
                    inherit area hotEdges;
                    left = (mkZone {
                      "x" = area."x";
                      "y" = area."y";
                      "width" = area."width" / 2;
                      "height" = area."height";
                    } "left-center");
                    right = (mkZone {
                      "x" = area."x" + (area."width" / 2);
                      "y" = area."y";
                      "width" = area."width" / 2;
                      "height" = area."height";
                    } "right-center");
                  }
                );
                mkQuadriSplit = parentZone: hotEdges: (
                  let
                    area = (mkArea parentZone.area parentZone.hotEdges);
                  in { # 4 zones in a grid
                    inherit area hotEdges;
                    topLeft = (mkZone {
                      "x" = area."x";
                      "y" = area."y";
                      "width" = area."width" / 2;
                      "height" = area."height" / 2;
                    } "top-left");
                    topRight = (mkZone {
                      "x" = area."x" + (area."width" / 2);
                      "y" = area."y";
                      "width" = area."width" / 2;
                      "height" = area."height" / 2;
                    } "top-right");
                    bottomLeft = (mkZone {
                      "x" = area."x";
                      "y" = area."y" + (area."height" / 2);
                      "width" = area."width" / 2;
                      "height" = area."height" / 2;
                    } "bottom-left");
                    bottomRight = (mkZone {
                      "x" = area."x" + (area."width" / 2);
                      "y" = area."y" + (area."height" / 2);
                      "width" = area."width" / 2;
                      "height" = area."height" / 2;
                    } "bottom-right");
                  }
                );

                # Zones
                fullscreen = (mkNoSplit screen [ "top" ]);
                verticals = (mkVerticalSplit fullscreen []); # Not used enough to justify hotEdges
                quadriGrid = (mkQuadriSplit verticals []); # Not used enough to justify hotEdges
                horizontals = (mkHorizontalSplit quadriGrid [ "left" "right" ]);

              in [
                # Fullscreen
                fullscreen.full
                # Verticals
                verticals.top
                verticals.bottom
                # QuadriGrid
                quadriGrid.topLeft
                quadriGrid.topRight
                quadriGrid.bottomLeft
                quadriGrid.bottomRight
                # Horizontals
                horizontals.left
                horizontals.right
              ] # The ones at the bottom have more priority
            );
          }
        }]";
      };
    };

    # Shortcut
    programs.plasma.shortcuts = { # (plasma-manager option)
      "kwin" = {
        # Disable all shortcuts
        # Everything is done with the mouse
        "KZones: Activate layout 1" = "none";
        "KZones: Activate layout 2" = "none";
        "KZones: Activate layout 3" = "none";
        "KZones: Activate layout 4" = "none";
        "KZones: Activate layout 5" = "none";
        "KZones: Activate layout 6" = "none";
        "KZones: Activate layout 7" = "none";
        "KZones: Activate layout 8" = "none";
        "KZones: Activate layout 9" = "none";
        "KZones: Cycle layouts" = "none";
        "KZones: Cycle layouts (reversed)" = "none";
        "KZones: Move active window down" = [ ];
        "KZones: Move active window left" = [ ];
        "KZones: Move active window right" = [ ];
        "KZones: Move active window to next zone" = "none";
        "KZones: Move active window to previous zone" = "none";
        "KZones: Move active window to zone 1" = "none";
        "KZones: Move active window to zone 2" = "none";
        "KZones: Move active window to zone 3" = "none";
        "KZones: Move active window to zone 4" = "none";
        "KZones: Move active window to zone 5" = "none";
        "KZones: Move active window to zone 6" = "none";
        "KZones: Move active window to zone 7" = "none";
        "KZones: Move active window to zone 8" = "none";
        "KZones: Move active window to zone 9" = "none";
        "KZones: Move active window up" = [ ];
        "KZones: Snap active window" = "none";
        "KZones: Snap all windows" = "none";
        "KZones: Switch to next window in current zone" = "none";
        "KZones: Switch to previous window in current zone" = "none";
        "KZones: Toggle zone overlay" = "none";
      };
    };

  });

}
