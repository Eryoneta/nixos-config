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
      description = "Fix Firefox-Dev(XWayland) launcher not sticking instances";
      match = { # What target
        window-class = {
          value = "Navigator firefox"; # A Firefox-Dev window
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
        title = {
          value = ".*Firefox Developer Edition$";
          type = "regex";
        };
      };
      apply = { # What changes
        "desktopfile" = {
          value = "firefox-devedition"; # Set the .desktop launcher
          apply = "initially"; # On start
        };
      };
      # TODO: (Firefox-Dev) Remove desktopFile rule once wayland works for Firefox
    }

    # Firefox-Dev: PiP onTop
    {
      description = "Stick Firefox-Dev PiP windows on top";
      match = { # What target
        window-class = {
          value = "firefox firefox-devedition"; # Firefox-Dev
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
        title = {
          value = "Picture-in-Picture";
          type = "exact";
        };
      };
      apply = { # What changes
        "above" = {
          value = true; # Set the window.to be above
          apply = "initially"; # On start
        };
      };
    }

    # Set sizes
    {
      description = "Start Firefox-Dev with a set size";
      match = { # What target
        window-class = {
          value = "firefox firefox-devedition"; # Firefox-Dev
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
      description = "Start Firefox-Dev(XWayland) with a set size";
      match = { # What target
        window-class = {
          value = "Navigator firefox"; # A Firefox-Dev window
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
        title = {
          value = ".*Firefox Developer Edition$";
          type = "regex";
        };
      };
      apply = { # What changes
        "size" = {
          value = "${screen.halfWidth},${screen.height}"; # Set the window.size
          apply = "initially"; # On start
        };
      };
      # TODO: (Firefox-Dev) Remove size rule once wayland works for Firefox
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