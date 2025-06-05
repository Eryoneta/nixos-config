{ userDev, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Dolphin: File manager
  config.modules."dolphin" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    setup = { attr }: {
      home = { config, config-domain, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.dolphin ];

        # Dotfile
        config.programs.plasma.configFile."dolphinrc" = { # (plasma-manager option)
          "General" = {
            "ShowFullPathInTitlebar" = false; # Do not show path in window title
            "ShowFullPath" = true; # Show full path in address
            "RememberOpenedTabs" = false; # Always start clean
            "BrowseThroughArchives" = true; # Navigate through archive files
            "GlobalViewProps" = false; # Remember the view configurations for each different folder
            "DoubleClickViewAction" = "view_redisplay"; # Double click on background = Refresh folder content
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
            "IconSize" = 96; # Icon size
            #"PreviewSize" = 32; # Preview content icon size
            "PreviewSize" = 96; # Preview content icon size
            # Note: It seems that "IconSize" means nothing? And "PreviewSize" is the actual icon size?
            # TODO: (Dolphin) Check if "PreviewSize" is corrected to be the actual size of the tiny icons
            "MaximumTextLines" = 5; # Allowed number of lines for the filename
            "TextWidthIndex" = 1; # (Menu index option) Text width per item
          };
          "CompactMode" = {
            "IconSize" = 16; # Icon size
            "PreviewSize" = 16; # Preview content icon size
          };
          "DetailsMode" = {
            "IconSize" = 16; # Icon size
            "PreviewSize" = 16; # Preview content icon size
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

        # Dotfile: Toolbar and shortcuts
        config.xdg.dataFile."kxmlgui5/dolphin/dolphinui.rc" = with config-domain; {
          source = (
            # Only the developer should be able to modify the file
            utils.mkIfElse (config.home.username == userDev.username) (
              utils.mkOutOfStoreSymlink "${outOfStore.public.dotfiles}/dolphin/.local/share/kxmlgui5/dolphin/dolphinui.rc"
            ) (
              "${public.dotfiles}/dolphin/.local/share/kxmlgui5/dolphin/dolphinui.rc"
            )
          );
        };

        # Dotfile: General
        config.programs.plasma.configFile."kdeglobals" = { # (plasma-manager option)
          "PreviewSettings" = {
            "EnableRemoteFolderThumbnail" = false; # Show thumbnails for remote
            "MaximumRemoteSize" = 10485760; # 10MB: Max file size allowed to get a thumbnail
          };
        };

      };
    };
  };

}
