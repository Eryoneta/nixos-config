{ host, ... }@args: with args.config-utils; {

    imports = [
      ./configuration/boot-loader.nix
      ./configuration/external-devices.nix
      ./configuration/networking.nix
      ./configuration/gui.nix
      ./configuration/security.nix
    ] ++ [
      ./features.nix
      ./programs.nix
      ./users.nix
    ];

    config = {

      # Current-Configuration label
      system.nixos.label = (mkFunc.formatStr host.system.label); #[a-zA-Z0-9:_.-]*

      # Start version
      system.stateVersion = "24.05"; # NixOS start version. (Default options).
      # (More with "man configuration.nix" or "https://nixos.org/nixos/options.html").
      
    };

  }
