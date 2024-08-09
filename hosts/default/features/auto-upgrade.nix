{ config, host, lib, auto-upgrade-pkgs, ... }:
  let
      mkDefault = value: lib.mkDefault value;
  in {

    imports = [
      ../../../modules/auto-upgrade-git-support.nix
      ../../../modules/auto-upgrade-update-flake-lock.nix
      ../../../modules/auto-upgrade-alter-profile.nix
    ];

    config = {
      # System AutoUpgrade
      system.autoUpgrade = {
        enable = mkDefault true;
        operation = "boot";
        allowReboot = false;
        persistent = true;
        dates = mkDefault "Tue *-*-* 16:00:00"; # Toda sexta, 16h00
        randomizedDelaySec = mkDefault "30min"; # Varia em 30min(Para não travar a rede em conjunto com outros PCs)
        flake = "git+file://${host.configFolder}#${host.user.name}@${host.name}";

        gitSupport = {
          enable = mkDefault true;
          systemUser = host.user.username;
          directory = host.configFolder;
          markDirectoryAsSafe = mkDefault true;
          push = mkDefault true;
        };

        updateFlakeLock = {
          enable = mkDefault true;
          inputs = auto-upgrade-pkgs;
          commitLockFile = mkDefault true; # Grava "flake.lock"
        };

        alterProfile = {
          enable = mkDefault true;
          name = mkDefault "System_Updates";
          configurationLimit = mkDefault 24;
        };
        
      };
    };

  }
