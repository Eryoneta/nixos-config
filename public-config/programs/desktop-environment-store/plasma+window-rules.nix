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
      desktopfile = { # Set the .desktop launcher
        value = "codium";
        apply = "initially"; # On start
      };
    };
  }
]