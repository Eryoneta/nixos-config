{ config, pkgs, host, lib, ... }:
  let
    # Depende de "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
    # Depende de "flake"
    # Depende de "nix-commands"
    # Depende de "./auto-upgrade-git-support.nix"
    cfg = config.system.autoUpgrade;
    cfg_ufl = config.system.autoUpgrade.updateFlakeLock;
  in {
    imports = [ ./auto-upgrade-git-support.nix ];
    options = {
      system.autoUpgrade.updateFlakeLock = {
        enable = lib.mkEnableOption "Enables updates to flake.lock file.";
        inputs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [
            "nixpkgs"
            "home-manager"
          ];
          description = ''
            Any specifics inputs to update.

            If empty, all inputs are updated.
          '';
        };
        directory = lib.mkOption {
          type = lib.types.str;
          description = ''
            The path to the flake directory.

            The default is {option}`system.autoUpgrade.gitSupport.directory`.
          '';
          default = config.system.autoUpgrade.gitSupport.directory;
        };
        commitLockFile = lib.mkEnableOption ''
          Commits the flake.lock file.

          It requires the options {option}`system.autoUpgrade.gitSupport.enable` and {option}`system.autoUpgrade.flake` to be set.
        '';
      };
    };
    config = lib.mkIf (cfg.enable && cfg_ufl.enable) (
      let
        cfg_gs = config.system.autoUpgrade.gitSupport;
      in {
        assertions = [
          {
            assertion = !(cfg_ufl.enable && cfg.flake == null);
            message = ''
              The option 'system.autoUpgrade.updateFlakeLock' requires 'system.autoUpgrade.flake' to be set
            '';
          }
          {
            assertion = !(cfg_ufl.directory == "");
            message = ''
              The option 'system.autoUpgrade.updateFlakeLock.directory' cannot be empty
            '';
          }
          {
            assertion = !(cfg_ufl.commitLockFile && !cfg_gs.enable);
            message = ''
              The option 'system.autoUpgrade.updateFlakeLock.commitLockFile' requires 'system.autoUpgrade.gitSupport' to be enabled
            '';
          }
        ];
        systemd.services."nixos-upgrade-update-flake-lock" = {
          serviceConfig.Type = "oneshot";
          serviceConfig.User = cfg_gs.systemUser;
          path = with pkgs; [
            coreutils
            git
            nixVersions.nix_2_19
          ];
          script = ''
            # Interrompe se houver erro ou variável indefinida
            set -eu
            # Nix Flake Update
            echo "Updating flake.lock..."
            nix flake update ${toString cfg_ufl.inputs} ${lib.optionalString cfg_ufl.commitLockFile "--commit-lock-file"} --flake "${cfg_ufl.directory}"
          '';
        };
        # Deve ocorrer entre 'git pull' e 'git push'
        systemd.services."nixos-upgrade-git-prepare" = {
          wants = lib.mkIf cfg_gs.enable [ "nixos-upgrade-update-flake-lock.service" ];
          before = lib.mkIf cfg_gs.enable [ "nixos-upgrade-update-flake-lock.service" ];
        };
        systemd.services."nixos-upgrade-update-flake-lock" = {
          wants = lib.mkIf cfg_gs.enable [ "nixos-upgrade-git-conclude.service" ];
          before = lib.mkIf cfg_gs.enable [ "nixos-upgrade-git-conclude.service" ];
        };
        # Upgrade deve iniciar apenas após este
        systemd.services."nixos-upgrade" = {
          wants = [ "nixos-upgrade-update-flake-lock.service" ];
          after = [ "nixos-upgrade-update-flake-lock.service" ];
        };
      }
    );
  }
