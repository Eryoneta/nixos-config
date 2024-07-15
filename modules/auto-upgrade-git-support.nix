{ config, pkgs, lib, ... }:
  let
    # Depende de "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
    # Depende de "Git >v2.22"
    cfg = config.system.autoUpgrade;
    cfg_gs = config.system.autoUpgrade.gitSupport;
  in {
    options = {
      system.autoUpgrade.gitSupport = {
        enable = lib.mkEnableOption "Enables Git support for system updates.";
        systemUser = lib.mkOption {
          type = lib.types.str;
          description = "The system user to execute Git commands.";
          default = "root";
        };
        directory = lib.mkOption {
          type = lib.types.path;
          description = "The path to the Git directory.";
        };
        pull = lib.mkEnableOption "Pulls commits from remote.";
        commit = lib.mkEnableOption "Realizes a commit of all files.";
        push = lib.mkEnableOption "Pushes any commits that there are.";
      };
    };
    config = lib.mkIf (cfg.enable && cfg_gs.enable) {
      assertions = [
        {
          assertion = !(cfg_gs.directory == "");
          message = ''
            The option 'system.autoUpgrade.gitSupport.directory' cannot be empty
          '';
        }
      ];
      # Git Pull & Git Commit
      systemd.services."nixos-upgrade-git-prepare" = {
        serviceConfig.Type = "oneshot";
        serviceConfig.User = cfg_gs.systemUser;
        path = with pkgs; [
          coreutils
          git # Git >v2.22
        ];
        script = ''
          # Interrompe se houver erro ou variável indefinida
          set -eu
          # Acessa pasta
          cd "${cfg_gs.directory}"
          # Git Pull
          ${lib.optionalString cfg_gs.pull ''
            echo "Pulling the latest version..."
            git pull --recurse-submodules
          ''}
          # Git Commit
          ${lib.optionalString cfg_gs.commit ''
            echo "Applying changes..."
            git add -A
            git commit -m "Configuration: Update"
          ''}
        '';
      };
      # Git Push
      systemd.services."nixos-upgrade-git-conclude" = {
        serviceConfig.Type = "oneshot";
        serviceConfig.User = cfg_gs.systemUser;
        path = with pkgs; [
          coreutils
          git # Git >v2.22
          config.programs.ssh.package
        ];
        script = ''
          ${lib.optionalString cfg_gs.push ''
            # Interrompe se houver erro ou variável indefinida
            set -eu
            # Acessa pasta
            cd "${cfg_gs.directory}"
            # Git Push
            echo "Pushing changes..."
            git push
          ''}
        '';
      };
      # Git Push deve ser feito apenas depois de Git Pull & Commit
      systemd.services."nixos-upgrade-git-prepare" = {
        wants = [ "nixos-upgrade-git-conclude.service" ];
        before = [ "nixos-upgrade-git-conclude.service" ];
      };
      # Upgrade deve iniciar apenas após ambos
      systemd.services."nixos-upgrade" = {
        wants = [ "nixos-upgrade-git-prepare.service" "nixos-upgrade-git-conclude.service" ];
        after = [ "nixos-upgrade-git-prepare.service" "nixos-upgrade-git-conclude.service" ];
      };
    };
  }
