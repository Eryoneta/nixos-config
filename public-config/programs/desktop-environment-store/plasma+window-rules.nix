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

    # Launchers
    {
      description = "Fix VSCodium launcher not sticking instances";
      match = { # What target
        window-class = {
          value = "vscodium VSCodium"; # A VSCodium window
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
        window-role = {
          value = "browser-window";
          type = "exact";
        };
      };
      apply = { # What changes
        "desktopfile" = {
          value = "codium"; # Set the .desktop launcher
          apply = "initially"; # On start
        };
      };
    }

    # MPV: OnTop
    {
      description = "Stick MPV windows on top";
      match = { # What target
        window-class = {
          value = "mpv mpv"; # MPV
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
        title = {
          value = ".* - mpv \\<Pinned\\>$";
          type = "regex";
        };
      };
      apply = { # What changes
        "above" = {
          value = true; # Set the window.to be above
          apply = "force"; # Force
        };
      };
    }
    {
      description = "Unstick MPV windows from top";
      match = { # What target
        window-class = {
          value = "mpv mpv"; # MPV
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
        title = {
          value = ".* - mpv$";
          type = "regex";
        };
      };
      apply = { # What changes
        "above" = {
          value = false; # Set the window.to be above
          apply = "force"; # Force
        };
      };
    }

    # Firefox: PiP onTop
    {
      description = "Stick Firefox PiP windows on top";
      match = { # What target
        window-class = {
          value = "firefox firefox"; # Firefox
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
      description = "Start Firefox with a set size";
      match = { # What target
        window-class = {
          value = "firefox firefox"; # Firefox
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
      description = "Start Firefox(XWayland) with a set size";
      match = { # What target
        window-class = {
          value = "Navigator firefox"; # A Firefox window
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
      # TODO: (Firefox) Remove size rule once wayland works for Firefox
    }

    # Set positions
    {
      description = "Set MPV start position";
      match = { # What target
        window-class = {
          value = "mpv mpv"; # A MPV window
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
      };
      apply = { # What changes
        "position" = {
          value = "${screen.halfWidth},0"; # Set the window.position
          apply = "initially"; # On start
        };
      };
    }
    {
      description = "Set KWrite start position";
      match = { # What target
        window-class = {
          value = "kwrite org.kde.kwrite"; # A KWrite window
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
      };
      apply = { # What changes
        "position" = {
          value = "${screen.halfWidth},0"; # Set the window.position
          apply = "initially"; # On start
        };
      };
    }
    {
      description = "Set SystemMonitor start position";
      match = { # What target
        window-class = {
          value = "plasma-systemmonitor org.kde.plasma-systemmonitor"; # A SystemMonitor window
          type = "exact";
        };
        window-types = [ "normal" ]; # Normal window
      };
      apply = { # What changes
        "position" = {
          value = "0,0"; # Set the window.position
          apply = "initially"; # On start
        };
      };
    }

  ]
)