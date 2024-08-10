{ config, options, pkgs, lib, ... }:
  let
    # Depends of "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
    # Depends of "flake"
    # Depends of "nix-commands"
    # Optionally depends of "./auto-upgrade-git-support.nix"
    cfg = config.system.autoUpgrade;
    cfg_ufl = config.system.autoUpgrade.updateFlakeLock;
  in {

    imports = [ ] ++ (lib.optional (builtins.pathExists ./auto-upgrade-git-support.nix) ./auto-upgrade-git-support.nix);

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

    config = lib.mkIf (cfg.enable && cfg_ufl.enable) (
      let
        # Default options
        cfg_gs = {
          enable = false;
          systemUser = "root";
          directory = "";
        # If "gitSupport" is present, uses it
        } // (lib.optionalAttrs (builtins.hasAttr "gitSupport" options.system.autoUpgrade) {
          enable = cfg.gitSupport.enable;
          systemUser = cfg.gitSupport.systemUser;
          directory = cfg.gitSupport.directory;
        });
      in {

        # Has to be "updateFlakeLock.directory = gitSupport.directory" as said
        system.autoUpgrade.updateFlakeLock.directory = lib.mkDefault cfg_gs.directory;

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

        # Update "flake.lock"
        systemd.services."nixos-upgrade-update-flake-lock" = {
          serviceConfig.Type = "oneshot";
          serviceConfig.User = cfg_gs.systemUser;
          path = with pkgs; [
            coreutils
            git
            nixVersions.nix_2_19 # Only "Nix >= v2.19" allows multiple "nix flake update" inputs!
          ];
          script = ''
            # Interrompe se houver erro ou variável indefinida
            set -eu
            # Nix Flake Update
            echo "Updating flake.lock..."
            nix flake update ${toString cfg_ufl.inputs} ${lib.optionalString cfg_ufl.commitLockFile "--commit-lock-file"} --flake "${cfg_ufl.directory}"
            # Git deve ser usado para mudar o nome do autor
            # Acessa pasta
            cd "${cfg_ufl.directory}"
            # Se o arquivo modificado é o 'flake.lock', então 'git commit' para mudar o nome do autor
            if [[ $(git diff --name-only HEAD HEAD~1) == 'flake.lock' ]]; then
              # Muda o nome do autor do commit
              git commit --amend --no-edit --author="NixOS AutoUpgrade <nixos@${config.networking.hostName}>";
            fi
          '';
        };

        # Has to happen between Git-Pull and Git-Push
        systemd.services."nixos-upgrade-git-prepare" = {
          wants = lib.mkIf cfg_gs.enable [ "nixos-upgrade-update-flake-lock.service" ];
          before = lib.mkIf cfg_gs.enable [ "nixos-upgrade-update-flake-lock.service" ];
        };
        systemd.services."nixos-upgrade-update-flake-lock" = {
          wants = lib.mkIf cfg_gs.enable [ "nixos-upgrade-git-conclude.service" ];
          before = lib.mkIf cfg_gs.enable [ "nixos-upgrade-git-conclude.service" ];
        };

        # NixOS-Upgrade starts only after this one
        systemd.services."nixos-upgrade" = {
          wants = [ "nixos-upgrade-update-flake-lock.service" ];
          after = [ "nixos-upgrade-update-flake-lock.service" ];
        };

      }
    );
  }
