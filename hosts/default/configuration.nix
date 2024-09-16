{ tools, config, host, ... }: with tools; {

    imports = [
      ./configuration/boot-loader.nix
      ./configuration/external-devices.nix
      ./configuration/networking.nix
      ./configuration/gui.nix
      ./configuration/security.nix
      ./configuration/variables.nix
    ] ++ [
      ./features.nix
      ./programs.nix
    ];

    # Default
    config = {

      # Current-Configuration label
      system.nixos.label = host.system.label; #[a-zA-Z0-9:_.-]*

      # Users
      users.users = {
        root = {
          hashedPasswordFile = config.age.secrets."root-userPassword".path;
        };
        ${host.user.username} = {
          description = host.user.name;
          isNormalUser = true;
          hashedPasswordFile = config.age.secrets."${host.user.username}-userPassword".path;
          extraGroups = [ "wheel" "networkmanager" ];
        };
      };

      # Start version
      system.stateVersion = "24.05"; # NixOS start version. (Default options).
      # (More with "man configuration.nix" or "https://nixos.org/nixos/options.html").
      
    };

  }
