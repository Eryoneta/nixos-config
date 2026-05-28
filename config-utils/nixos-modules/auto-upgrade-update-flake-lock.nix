# Upgrade Flake Lock for AutoUpgrade
/*
  - Allows the update of multiple flake-inputs before a nixos-upgrade
  - Optionally, can commit such updates
    - The commit author can be set!
  - Depends on "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
  - Uses "flake"
  - Uses "nix-commands"
  - Uses "git"
  - Optionally depends on "./auto-upgrade-git-support.nix"
*/
{ config, pkgs, lib, ... }:
  let
    cfg = config.system.autoUpgrade;
    cfg_ufl = config.system.autoUpgrade.updateFlakeLock;
    cfg_n = config.system.autoUpgrade.notifier or {};
    cfg_gs = config.system.autoUpgrade.gitSupport or {};
  in {

    options = {
      system.autoUpgrade.updateFlakeLock = {

        enable = lib.mkEnableOption "Enables updates to flake.lock file.";

        inputs = lib.mkOption {
          type = (lib.types.listOf (lib.types.str));
          default = [];
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
          type = lib.types.path;
          description = ''
            The path to the flake directory.

            The default is {option}`system.autoUpgrade.gitSupport.directory`.
          '';
        };

        commitLockFile = lib.mkEnableOption ''
          Commits the flake.lock file.

          It requires the options {option}`system.autoUpgrade.gitSupport.enable` and {option}`system.autoUpgrade.flake` to be set.
        '';

      };
    };

    config = lib.mkIf (cfg.enable && cfg_ufl.enable) {

      # Has to be "updateFlakeLock.directory = gitSupport.directory" as said
      system.autoUpgrade.updateFlakeLock.directory = (lib.mkDefault) (cfg_gs.directory or "");

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
          assertion = !(cfg_ufl.commitLockFile && !(cfg_gs.enable or false));
          message = ''
            The option 'system.autoUpgrade.updateFlakeLock.commitLockFile' requires 'system.autoUpgrade.gitSupport' to be enabled
          '';
        }
      ];

      # Update "flake.lock"
      systemd.services."nixos-upgrade-update-flake-lock" = (lib.mkMerge [
        { # Script
          serviceConfig = {
            "Type" = "oneshot";
            "User" = (cfg_gs.systemUser or "root");
          };
          path = with pkgs; [
            coreutils
            git
            nix
          ];
          script = ''
            # Interrupts if there is an error or undefined variable
            set -eu
            # Sleep
            echo "Waiting 10 seconds... to make sure Internet access is up..."
            sleep 10
            # Nix Flake Update
            echo "Updating flake.lock..."
            nix flake update ${builtins.toString cfg_ufl.inputs} ${lib.optionalString (cfg_ufl.commitLockFile) "--commit-lock-file"} --flake "${cfg_ufl.directory}"
            # Git needs to be used to change the author name
            # Access folder
            cd "${cfg_ufl.directory}"
            # If the modified file is 'flake.lock', then uses 'git commit' to change the author name
            if [[ $(git diff --name-only HEAD HEAD~1) == 'flake.lock' ]]; then
              # changes the author name
              git commit --amend --no-edit --author="NixOS AutoUpgrade <nixos@${config.networking.hostName}>";
            fi
          '';
        }
        { # Internet access is needed
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
        }
        # It should happen between "git-prepare" and "git-conclude", and it fails if the first one does
        (lib.mkIf (cfg_gs.enable or false) {
          requires = [ "nixos-upgrade-git-prepare.service" ];
          after = [ "nixos-upgrade-git-prepare.service" ];
          before = [ "nixos-upgrade-git-conclude.service" ];
        })
        # If there is a confirmation prompt, it should obey it
        (lib.mkIf (!(cfg_gs.enable or false) && ((cfg_n.enable or false) && (cfg_n.informStart.show or false) && (cfg_n.informStart.promptConfirmation or false))) {
          requires = [ "nixos-upgrade-notify-start.service" ];
          after = [ "nixos-upgrade-notify-start.service" ];
        })
      ]);

      # NixOS-Upgrade
      systemd.services."nixos-upgrade" = (lib.mkMerge [
        # Calls "update-flake-lock", and it fails if that one does
        (lib.mkIf (!(cfg_gs.enable or false)) {
          requires = [ "nixos-upgrade-update-flake-lock.service" ];
          after = [ "nixos-upgrade-update-flake-lock.service" ];
        })
      ]);

    };
  }
