{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Spectacle: Print-screen tool
  config.modules."spectacle" = {
    attr.packageChannel = pkgs-bundle.stable; # Not used (Included with KDE Plasma)
    tags = [ "default-setup" ];
    setup = {
      home = { config, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.spectacle = { # (plasma-manager option)

          # Shortcuts
          shortcuts = {
            launch = (utils.mkDefault) "Print"; # Launch Spectacle
            launchWithoutCapturing = (utils.mkDefault) "Meta+Print"; # Launch, but do not print
            captureCurrentMonitor = (utils.mkDefault) "Ctrl+Print"; # Print whole screen
            captureActiveWindow = (utils.mkDefault) "Alt+Print"; # Print only current focused window
            captureEntireDesktop = (utils.mkDefault) "Ctrl+Shift+Print"; # Print everything
            captureRectangularRegion = (utils.mkDefault) "Shift+Print"; # Print a rectangle (Asks where)
            captureWindowUnderCursor = (utils.mkDefault) ""; # Print the window under cursor
            recordRegion = (utils.mkDefault) ""; # Record a rectangle
            recordScreen = (utils.mkDefault) ""; # Record whole screen
            recordWindow = (utils.mkDefault) ""; # Record only a single window
          };

        };

        # Dotfile
        config.programs.plasma.configFile."spectaclerc" = { # (plasma-manager option)
          "General" = {
            "clipboardGroup" = "PostScreenshotCopyImage"; # On print, copy to clipboard
          };
          "ImageSave" = {
            "imageFilenameTemplate" = "img_<yyyy>-<MM>-<dd>_<hh>:<mm>:<ss>";
            "imageSaveLocation" = "file://${config.xdg.userDirs.pictures}/";
          };
          "VideoSave" = {
            "preferredVideoFormat" = 2; # Save as .mp4
            "videoFilenameTemplate" = "vid_<yyyy>-<MM>-<dd>_<hh>:<mm>:<ss>";
            "videoSaveLocation" = "file://${config.xdg.userDirs.videos}/";
          };
        };

      };
    };
  };

}
