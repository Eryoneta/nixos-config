{ config, pkgs-bundle, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; {

    # TiledMenu: Plasmoid for Plasma, is a start menu that shows apps in neat tiles
    xdg.dataFile."plasma/plasmoids/com.github.zren.tiledmenu" = {
      enable = options.enabled;
      source = "${pkgs-bundle.tiledmenu}/package";
    };

    # Configuration
    profile.programs.plasma = {
      # Content of "config.programs.plasma.panels.<1>.widgets.<1>"
      options.defaults.plasmoids.tiledmenu = {
        name = "com.github.zren.tiledmenu"; # "TiledMenu": Start menu with tiled apps
        config = {
          "popupWidth" = 800; # Menu width
          "popupHeight" = 540; # Menu height
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
            "appListWidth" = 300; # Width
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
            "tileModel" = "W3sieCI6MCwieSI6MTAsInciOjMsImgiOjEsInVybCI6IiIsInRpbGVUeXBlIjoiZ3JvdXAiLCJsYWJlbCI6IkV4cGxvcmFyIn0seyJ4IjowLCJ5IjoxMSwidyI6MiwiaCI6MiwidXJsIjoicHJlZmVycmVkOi8vYnJvd3NlciJ9LHsieCI6MywieSI6MiwidyI6MiwiaCI6MiwidXJsIjoiY2FsaWJyZS1ndWkuZGVza3RvcCJ9LHsieCI6MCwieSI6MCwidyI6MSwiaCI6MSwidXJsIjoiZmlyZWZveC5kZXNrdG9wIn0seyJ4IjoxLCJ5IjowLCJ3IjoxLCJoIjoxLCJ1cmwiOiJmaXJlZm94LWRldmVkaXRpb24uZGVza3RvcCJ9LHsieCI6MiwieSI6MiwidyI6MSwiaCI6MSwidXJsIjoib3JnLmtkZS5rYWxhcm0uZGVza3RvcCJ9LHsieCI6NSwieSI6MiwidyI6MSwiaCI6MSwidXJsIjoib3JnLmtkZS5rYXRlLmRlc2t0b3AifSx7IngiOjAsInkiOjEsInciOjEsImgiOjEsInVybCI6Im9yZy5rZGUua3RvcnJlbnQuZGVza3RvcCJ9LHsieCI6NCwieSI6NCwidyI6MiwiaCI6MiwidXJsIjoib3JnLmtkZS5rd3JpdGUuZGVza3RvcCJ9LHsieCI6MywieSI6NCwidyI6MSwiaCI6MSwidXJsIjoib3JnLmtkZS5rb25zb2xlLmRlc2t0b3AifSx7IngiOjMsInkiOjYsInciOjIsImgiOjIsInVybCI6ImNvZGl1bS5kZXNrdG9wIn1d";
            # TODO: (Plasma/TiledMenu) Recreate grid
          };
        };
      };
    };

  };
}
