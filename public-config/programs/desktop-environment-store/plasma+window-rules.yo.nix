# Content of "config.programs.plasma.window-rules" (home-manager+plasma-manager)
screenSize: (
  let
    screen = {
      width = builtins.toString (screenSize.width);
      height = builtins.toString (screenSize.height);
      halfWidth =  builtins.toString (screenSize.width / 2);
      halfHeight =  builtins.toString (screenSize.height / 2);
    };
  in [

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
          value = "${screen.halfWidth},${screen.height}"; # Set the window.size
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
          value = "380,440"; # Set the window.minimum size
          apply = "force"; # On start
        };
        "size" = {
          value = "380,440"; # Set the window.size
          apply = "initially"; # On start
        };
      };
    }

  ]
)