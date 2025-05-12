{ config, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.spectacle = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.spectacle; (lib.mkIf (options.enabled) {

    # Spectacle: Print-screen tool
    # (Included with KDE Plasma)

    # Configuration
    programs.plasma.spectacle = { # (plasma-manager option)

      # Shortcuts
      shortcuts = {
        launch = (utils.mkDefault) "Print"; # Launch Spectacle
        launchWithoutCapturing = (utils.mkDefault) "Meta+Print"; # Launch, but do not print
        captureCurrentMonitor = (utils.mkDefault) "Ctrl+Print"; # Print whole screen
        captureActiveWindow = (utils.mkDefault) "Alt+Print"; # Print only current focused window
        captureEntireDesktop = (utils.mkDefault) "Ctrl+Shift+Print"; # Print everything
        captureRectangularRegion = (utils.mkDefault) "Shift+Print"; # Print a rectangle (Asks where)
        captureWindowUnderCursor = (utils.mkDefault) ""; # Print the window under cursor
        recordScreen = (utils.mkDefault) ""; # Record whole screen
        recordWindow = (utils.mkDefault) ""; # Record only a single window
      };

    };
    programs.plasma.configFile."spectaclerc" = { # (plasma-manager option)
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

  });

}
