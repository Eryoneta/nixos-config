# Content of "config.programs.plasma.window-rules" (home-manager+plasma-manager)
[
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
      "desktopfile" = { # Set the .desktop launcher
        value = "codium";
        apply = "initially"; # On start
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
      "above" = { # Set the window.to be above
        value = true;
        apply = "initially"; # On start
      };
    };
  }
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
      "above" = { # Set the window.to be above
        value = true;
        apply = "initially"; # On start
      };
    };
  }
]