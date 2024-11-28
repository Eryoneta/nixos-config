{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.dolphin = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.dolphin; {

    # Dolphin: File manager
    # (Included with KDE Plasma)

    # Dotfile
    programs.plasma.configFile = utils.mkIf (options.enabled) {
      "dolphinrc" = {
        "General" = {
          "ShowFullPathInTitlebar" = true; # Show path in window title
          "ShowFullPath" = true; # Show full path in address
          "RememberOpenedTabs" = false; # Always start clean
          "BrowseThroughArchives" = true; # Navigate through archive files
        };
        "PreviewSettings" = { # Show preview of everything
          "Plugins" = "appimagethumbnail,cursorthumbnail,fontthumbnail,ffmpegthumbs,audiothumbnail,djvuthumbnail,blenderthumbnail,mobithumbnail,gsthumbnail,rawthumbnail,comicbookthumbnail,opendocumentthumbnail,kraorathumbnail,ebookthumbnail,windowsexethumbnail,imagethumbnail,windowsimagethumbnail,exrthumbnail,jpegthumbnail,svgthumbnail,directorythumbnail";
        };
        "ContentDisplay" = {
          "UseShortRelativeDates" = false; # Show absolute dates
        };
        # Window
        "MainWindow" = {
          "MenuBar" = "Disabled"; # Do not show menubar
          "ToolBarsMovable" = "Disabled"; # Not moveable
        };
        # Sidebar
        "KFileDialog Settings" = {
          "Places Icons Auto-resize" = false; #Do not resize icons
          "Places Icons Static Size" = 16; # Icon size
        };
        "PlacesPanel" = {
          "IconSize" = 16; # Icon size
        };
        # View modes
        "IconsMode" = {
          "PreviewSize" = 48; # Icon size
        };
        "CompactMode" = {
          "PreviewSize" = 16; # Icon size
        };
        "DetailsMode" = {
          "PreviewSize" = 16; # Icon size
          "ExpandableFolders" = false; # Do not expand folders
        };
        # Context menu
        "ContextMenu" = {
          "ShowCopyToOtherSplitView" = false; # Split view is not used
          "ShowMoveToOtherSplitView" = false; # Split view is not used
        };
        # Git plugin
        "VersionControl" = {
          "enabledPlugins" = "Git";
        };
      };
    };

    # Dotfile: Toolbar and shortcuts
    xdg.dataFile."kxmlgui5/dolphin/dolphinui.rc" = with config-domain; {
      enable = (options.enabled);
      source = with outOfStore.public; (
        utils.mkOutOfStoreSymlink (
          "${dotfiles}/dolphin/.local/share/kxmlgui5/dolphin/dolphinui.rc"
        )
      );
    };

  };

}
