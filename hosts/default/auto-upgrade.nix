{ config, pkgs, host, lib, ... }:
  let
      mkDefault = value: lib.mkDefault value;
  in {
    imports = [
      ../../modules/auto-upgrade-git-support.nix
      ../../modules/auto-upgrade-update-flake-lock.nix
      ../../modules/auto-upgrade-alter-profile.nix
    ];
    config = {
      # System AutoUpgrade
      system.autoUpgrade = {
        enable = mkDefault true;
        operation = "boot";
        allowReboot = false;
        persistent = true;
        dates = "Tue *-*-* 16:00:00"; # Toda sexta, 16h00
        randomizedDelaySec = "10min"; # Varia em 10min(Para não travar a rede em conjunto com outros PCs)
        flake = "git+file://${host.configFolder}#${host.user.name}@${host.name}";
        gitSupport = {
          enable= true;
          systemUser = host.user.username;
          directory = host.configFolder;
          remote = "origin";
          branches = {
            local = "main";
            remote = "main";
          };
          push = true;
        };
        updateFlakeLock = {
          enable = true;
          inputs = [
            "nixpkgs"       # Update nixos
            "home-manager"  # Update home-manager
          ];
          commitLockFile = true; # Grava "flake.lock"
        };
        alterProfile = {
          enable = true;
          name = "System_Updates";
          configurationLimit = 24;
        };
      };
    };
  }
