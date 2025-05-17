{ ... }@args: with args.config-utils; {
  config = {
    
    # XDG Desktop Entries
    xdg = {
      desktopEntries = {
        "nixos-manual" = { # Override "NixOS Manual"
          name = "NixOS Manual";
          exec = "nixos-help";
          noDisplay = true; # Hide
        };
      };
    };

  };
}
