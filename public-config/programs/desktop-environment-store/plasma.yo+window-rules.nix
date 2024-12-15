# Content of "config.programs.plasma.window-rules" (home-manager+plasma-manager)
[
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
      "size" = { # Set the window.to be above
        value = "683,724";
        apply = "initially"; # On start
      };
    };
  }
]