# Content of "config.programs.plasma.window-rules" (home-manager+plasma-manager)
[
  {
    description = "Fix VSCodium launcher not sticking instances";
    match = { # What target
      window-class = {
        value = "VSCodium"; # A VSCodium window
        type = "exact";
      };
      window-types = [ "normal" ]; # Normal window
    };
    apply = { # What changes
      desktopfile = { # Set the .desktop launcher
        value = "codium";
        apply = "initially"; # On start
      };
    };
  }
]