{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # scrcpy
  config.modules."scrcpy" = {
    tags = [ "personal-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)

        # Install
        config.environment.systemPackages = with attr.packageChannel; [
          scrcpy # scrcpy: Screen Copy
          android-tools # adb: Android Debug Bridge
        ];

        # Configuration
        #config.programs.adb.enable = true; # Starts the ADB server
        # Note: Not really necessary, as the server can be started by scrcpy
        config.boot = {
          kernelModules = [ "v4l2loopback" ]; # Adds a "Video4Linux" module
          extraModulePackages = [ (attr.packageChannel).linuxPackages.v4l2loopback ];
          extraModprobeConfig = ''
            options v4l2loopback exclusive_caps=1 card_label="Virtual Webcam"
          '';
          # Note: Creates a device, with a label, and marked as an output only
        };

      };
      home = { # (Home-Manager Module)

        # Desktop entry
        config.xdg.desktopEntries."virtcam" = {
          name = "Android Virtual Camera";
          icon = "camera-web-symbolic";
          comment = "Feed a Android device camera into a virtual webcam feed";
          exec = "scrcpy --video-source=camera --camera-facing=back --no-audio --v4l2-sink=/dev/video0 --max-size=1024";
          # Note: Get the camera (The back camera), without audio, and shove the results into "video0"
          #   "--max-size=1024" is here so it doesn't crash
          #   Running this, allows any other app to read "video0" to get a video feed
          categories = [ "Office" ];
          type = "Application";
          terminal = false;
        };
        # Note: It can silently fail!

        # Steps:
        #   The Android device needs to have USB debugging enabled
        #     5 Taps into "Settings" > "About phone" generally enables "Developer Mode"
        #     "Developer options" allows to enable "USB debugging"
        #   Important: After connected, the USB connection needs to be in "Transfer files mode"!
        #     ...Maybe? Not really?
        #   A popup requests a USB debug permission
        #     Might require to try again, after accepting

      };
    };
  };

}
