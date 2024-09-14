{ host, lib, modules, ... }:
  let
      mkDefault = value: lib.mkDefault value;
  in {

    imports = [
      ./features/auto-upgrade.nix # Auto-Upgrade
      modules.nixos-modules."link-to-source-config.nix"
    ];

    config = {
      
      # Auto-login
      services.displayManager = {
        autoLogin.enable = mkDefault false;
        autoLogin.user = host.user.username;
      };

      # Link to source configuration
      system.linkToSourceConfiguration = {
        enable = true;
        configurationPath = host.configFolderNixStore;
      };

    };

  }
