{ config, lib, config-domain, ... }@args: with args.config-utils; { # (Setup Module)

  # TiledMenu: Plasmoid for Plasma, is a start menu that shows apps in neat tiles
  config.modules."plasma-tiledmenu" = {
    attr = rec {
      apps = { # List of all apps to be present in the grid
        __ = ""; # Empty space
        # Browsers
        Ch = "chromium-browser.desktop";
        Ff = "firefox.desktop";
        # System
        SS = "systemsettings.desktop";
        PA = "org.pulseaudio.pavucontrol.desktop";
        EE = "com.github.wwmm.easyeffects.desktop";
        KI = "org.kde.kinfocenter.desktop";
        MC = "io.missioncenter.MissionCenter.desktop";
        # Utilities
        KC = "org.kde.kalk.desktop";
        Wr = "writer.desktop";
        Ca = "calc.desktop";
        # Development
        KW = "org.kde.kwrite.desktop";
        Ka = "org.kde.kate.desktop";
        Ko = "org.kde.konsole.desktop";
        Ec = "Eclipse.desktop";
        Co = "codium.desktop";
        Ho = "hoppscotch.desktop";
        MW = "mysql-workbench.desktop";
        # Images
        KP = "org.kde.kolourpaint.desktop";
        # Videos
        Mp = "mpv.desktop";
        Ob = "com.obsproject.Studio.desktop";
      };
      gridModel = (with apps; [ # The grid
        [ Ch Ff __ KW KW Ka Ec __ KP KP ]
        [ __ __ __ KW KW Ko __ __ KP KP ]
        [ SS __ __ Co Co Ho __ __ __ __ ]
        [ PA KC __ Co Co MW __ __ __ __ ]
        [ EE Wr __ __ __ __ __ __ __ __ ]
        [ KI Ca __ Mp Mp __ __ __ __ __ ]
        [ MC __ __ Mp Mp Ob __ __ __ __ ]
      ]);
      tiledmenu = apps: gridModel: (
        let
          gridFactory = apps: gridModel: (
            let
              findXIndex = url: grid: defaultValue: (
                lib.lists.findFirst (x: x > -1) defaultValue ( # Returns "defaultValue" or index
                  builtins.map (row: ( # Transforms a list-of-lists into a list-of-indexes
                    lib.lists.findFirstIndex (itemUrl: itemUrl == url) (-1) row # Returns -1 or index
                  )) grid
                )
              );
              findYIndex = url: grid: defaultValue: (
                lib.lists.findFirstIndex (tileMatch: tileMatch) defaultValue ( # Returns -"defaultValue" or index
                  builtins.map (row: ( # Transforms a list-of-lists into a list-of-presence(true or false)
                    builtins.any (itemUrl: itemUrl == url) row # Returns true or false
                  )) grid
                )
              );
              findWidth = url: grid: defaultValue: (
                lib.lists.findFirst (x: x > 0) defaultValue ( # Returns "defaultValue" or quantity(Total width)
                  builtins.map (row: ( # Transforms a list-of-lists into a list-of-quantities
                    lib.lists.count (itemUrl: itemUrl == url) row # Returns quantity
                  )) grid
                )
              );
              findHeight = url: grid: defaultValue: (
                let
                  func = (lib.lists.count (tileMatch: tileMatch) ( # Returns quantity(Total height)
                    builtins.map (row: ( # Transforms a list-of-lists into a list-of-presence(true or false)
                      builtins.any (itemUrl: itemUrl == url) row # Returns true or false
                    )) grid
                  ));
                in if (func == 0) then defaultValue else func # Returns "defaultValue" or quantity(Total height)
              );
              mkTile = url: gridModel: {
                x = (findXIndex url gridModel 0);
                y = (findYIndex url gridModel 0);
                w = (findWidth url gridModel 1);
                h = (findHeight url gridModel 1);
                inherit url;
              };
              mkGrid = apps: gridModel: (
                builtins.mapAttrs (
                  id: url: (mkTile url gridModel)
                ) (builtins.removeAttrs apps [ "__" ]) # Ignore empty spaces
              );
              toJSON = grid: (
                utils.toJSON (builtins.attrValues grid)
              );
              toBase64 = ((builtins.import "${config-domain.public.dotfiles}/plasma-widget-tiled-menu/base64.nix"){ inherit lib; }).toBase64;
            in (toBase64 (toJSON (mkGrid apps gridModel)))
          );
        in {
          name = "com.github.zren.tiledmenu";
          config = (
            let
              gridWidth = (builtins.length (builtins.head gridModel));
              gridHeight = (builtins.length gridModel);
              border = 4; # 4px
              tileSize = 64; # 4px + 56px + 4px
              menuWidth = 48; # 48px
              listWidth = 300; # 300px
              #popupWidth = (border + menuWidth + listWidth + border + (tileSize * gridWidth) + border);
              #popupHeight = (border + (tileSize * gridHeight) + border);
              popupWidth = (menuWidth + listWidth + border + (tileSize * gridWidth));
              popupHeight = (tileSize * gridHeight);
              # Note: It seems like the popup already have borders?
            in {
              "popupWidth" = popupWidth; # Menu width
              "popupHeight" = popupHeight; # Menu height
              "General" = {
                "icon" = "nix-snowflake-white"; # Icon
                # TODO: (Plasma/TiledMenu) Set a custom icon
                # Sidebar
                "sidebarFollowsTheme" = true; # Theme
                "sidebarShortcuts" = (utils.joinStr "," [ # Shortcuts
                # TODO: (Plasma/TiledMenu) Side-shortcuts not being written??? Fix
                  "org.kde.dolphin.desktop" # Dolphin
                  "systemsettings.desktop" # Settings
                ]);
                # List
                "appListWidth" = listWidth; # Width
                "defaultAppListView" = "Categories"; # How to organize all the apps
                "showRecentApps" = false; # Do not show recent apps
                "favoritesPortedToKAstats" = true; # ?
                # TODO: (Plasma/TiledMenu) Understand "favoritesPortedToKAstats"
                # List: Search field
                "hideSearchField" = true; # Do not show the search field
                "searchFieldFollowsTheme" = true; # Search field theme
                "searchFieldHeight" = 32; # Search field height
                # Tile
                "defaultTileGradient" = true; # Gradient background
                "tileLabelAlignment" = "center"; # Center tile label
                "groupLabelAlignment" = "center"; # Center group label
                # Tile: Model
                # Needs to be generated by "TiledMenu"
                "tileModel" = (gridFactory apps gridModel);
              };
            }
          );
        }
      );
    };
    tags = config.modules."plasma".tags;
    setup = {
      home = { pkgs-bundle, ... }: { # (Home-Manager Module)

        # Install
        config.xdg.dataFile."plasma/plasmoids/com.github.zren.tiledmenu" = {
          source = "${pkgs-bundle.tiledmenu}/package";
        };

      };
    };
  };

}
