{ config, host, lib, ... }:
  let
      mkDefault = value: lib.mkDefault value;
  in {

    imports = [
      ./features/auto-upgrade.nix # Auto-Upgrade
    ];
    
    # Autologin
    services.displayManager = {
      autoLogin.enable = mkDefault false;
      autoLogin.user = host.user.username;
    };

    # Source Code
    system.extraSystemBuilderCmds = "ln -s ${host.configFolderNixStore} $out/src";
    # "/run/current-system/src" is a link to the current flake source-code!

  }
