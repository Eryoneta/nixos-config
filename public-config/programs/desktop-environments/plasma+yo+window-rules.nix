{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Main panel
  config.modules."plasma+yo+window-rules" = {
    attr.workArea = with config.hardware.configuration.screenSize.workArea; { # (From "configurations/screen-size.nix")
      width = builtins.toString (width);
      height = builtins.toString (height);
      halfWidth =  builtins.toString (width / 2);
      halfHeight =  builtins.toString (height / 2);
    };
    tags = config.modules."plasma+yo".tags;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Window rules
        config.programs.plasma.window-rules = (utils.mkDefault) [ # (plasma-manager option)

          # Instances
          {
            description = "Fix Firefox-Dev launcher not sticking instances";
            match = { # What target
              window-class = {
                value = "Navigator firefox-dev"; # A Firefox-Dev window
                type = "exact";
              };
              window-types = [ "normal" ]; # Normal window
            };
            apply = { # What changes
              "desktopfile" = {
                value = "firefox-devedition"; # Set the .desktop launcher
                apply = "initially"; # On start
              };
            };
          }

          # Focus
          {
            description = "Unfocusable Chromium";
            match = { # What target
              window-class = {
                value = "chromium-browser Chromium-browser"; # Chromium
                type = "exact";
              };
            };
            apply = { # What changes
              "fsplevel" = {
                value = 3; # Stops the app from stealing focus
                apply = "force"; # Force
              };
            };
          }

          # Firefox-Dev: PiP onTop
          {
            description = "Stick Firefox-Dev PiP on all virtual desktops";
            match = { # What target
              window-class = {
                value = "Toolkit firefox-devedition"; # Firefox-Dev
                type = "exact";
              };
              window-types = [ "utility" ]; # Utility window
              window-role = {
                value = "PictureInPicture"; # PiP
                type = "exact";
              };
              title = {
                value = "Picture-in-Picture";
                type = "exact";
              };
            };
            apply = { # What changes
              "desktops" = {
                value = 0; # Set the window.to be on all virtual desktops
                apply = "initially"; # On start
              };
            };
          }

          # Set sizes
          {
            description = "Start Firefox-Dev with a set size";
            match = { # What target
              window-class = {
                value = "Navigator firefox-dev"; # A Firefox-Dev window
                type = "exact";
              };
              window-types = [ "normal" ]; # Normal window
            };
            apply = { # What changes
              "size" = {
                value = "${attr.workArea.halfWidth},${attr.workArea.height}"; # Set the window.size
                apply = "initially"; # On start
              };
            };
          }
          {
            description = "Alarm Clock with a fixed window size";
            match = { # What target
              window-class = {
                value = "alarm-clock-applet Alarm-clock-applet"; # Alarm Clock
                type = "exact";
              };
              window-types = [ "normal" ]; # Normal window
            };
            apply = { # What changes
              "ignoregeometry" = {
                value = true; # Ignore programs size requests
                apply = "force"; # Force
              };
              "minsize" = {
                value = "380,500"; # Set the window.minimum size
                apply = "force"; # On start
              };
              "size" = {
                value = "380,500"; # Set the window.size
                apply = "initially"; # On start
              };
            };
          }

        ];

      };
    };
  };

}
