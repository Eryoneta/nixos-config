# Content of "config.programs.plasma.window-rules" (home-manager+plasma-manager)
screenSize: [
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
  {
    description = "Stick MPV windows on top";
    match = { # What target
      window-class = {
        value = "mpv mpv"; # MPV
        type = "exact";
      };
      window-types = [ "normal" ]; # Normal window
      title = {
        value = ".* \\<Pinned\\>$";
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
        value = "${builtins.toString (screenSize.width / 2)},${builtins.toString screenSize.height}"; # Set the window.size
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
        value = "${builtins.toString (screenSize.width / 2)},${builtins.toString screenSize.height}"; # Set the window.size
        apply = "initially"; # On start
      };
    };
    # TODO: (Firefox) Remove size rule once wayland works for Firefox
  }
]