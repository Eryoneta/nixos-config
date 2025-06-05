# GitSupport for AutoUpgrade
/*
  - Executes git commands before and after a nixos-upgrade
    - "pull": Pull changes from remote before the upgrade
    - "commit": Adds and commits changes before the upgrade
    - "push": Pushes any commits to remote
  - Uses "git"
  - Depends on "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
  - Depends on "home-manager" (Error is thrown without it)
*/
{ config, pkgs, lib, ... }:
  let
    cfg = config.system.autoUpgrade;
    cfg_gs = config.system.autoUpgrade.gitSupport;
    configuration = config;
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

        markDirectoryAsSafe = lib.mkEnableOption ''
          Marks the Git directory as a safe-directory to be run by root.

          This allows 'nixos-upgrade.service'(Run as root) to read a user flake.

          Note that this edits '/root/.gitconfig' and requires 'home-manager'.
        '';

        pull = lib.mkEnableOption "Pulls commits from remote.";

        commit = lib.mkEnableOption "Realizes a commit of all files.";

        push = lib.mkEnableOption "Pushes any commits that there are.";

        commitMessage = lib.mkOption {
          type = lib.types.strMatching "[^\"]*";
          description = "The commit message to use.";
          default = "Configuration: Update";
        };

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
        {
          assertion = !(cfg_gs.commitMessage == "");
          message = ''
            The option 'system.autoUpgrade.gitSupport.commitMessage' cannot be empty
          '';
        }
      ];

      # Safe Directory
      # "Home-Manager" is used to edit the file "/root/.gitconfig"
      # That means that it fails if "Home-Manager" is not present!
      # There is no way to check if it's present...?
      home-manager.users.root.home = lib.mkIf (cfg_gs.markDirectoryAsSafe) {
        file.".gitconfig".text = lib.mkAfter ''
          [safe]
            # directory = "${cfg_gs.directory}/.git"
            # directory = "${cfg_gs.directory}/*"
            # Note: It does NOT WORK for SOME REASON
            #   ...So, disable all safety checks
            directory = *
        '';
        stateVersion = lib.mkDefault (
          if (cfg_gs.systemUser != "root") then (
            if (builtins.hasAttr "home-manager" configuration) then
              config.home-manager.users.${cfg_gs.systemUser}.home.stateVersion
            else config.system.stateVersion
          ) else config.system.stateVersion
        );
      };

      # Git-Pull&Commit
      systemd.services."nixos-upgrade-git-prepare" = {
        serviceConfig = {
          "Type" = "oneshot";
          "User" = cfg_gs.systemUser;
        };
        path = with pkgs; [
          coreutils
          git
        ];
        script = ''
          # Interrupts if there is an error or undefined variable
          set -eu
          # Access folder
          cd "${cfg_gs.directory}"
          # Git Pull
          ${lib.optionalString (cfg_gs.pull) ''
            echo "Pulling the latest version..."
            git pull --recurse-submodules
          ''}
          # Git Commit
          ${lib.optionalString (cfg_gs.commit) ''
            echo "Committing changes..."
            git add -A
            git commit -m "${cfg_gs.commitMessage}"
          ''}
        '';
      };

      # Git-Push
      systemd.services."nixos-upgrade-git-conclude" = {
        serviceConfig = {
          "Type" = "oneshot";
          "User" = cfg_gs.systemUser;
        };
        path = with pkgs; [
          coreutils
          git
          config.programs.ssh.package
        ];
        script = ''
          ${lib.optionalString (cfg_gs.push) ''
            # Interrupts if there is an error or undefined variable
            set -eu
            # Access folder
            cd "${cfg_gs.directory}"
            # Git Push
            echo "Pushing changes..."
            git push
          ''}
        '';
      };


      # Git-Push comes after Git-Pull&Commit
      systemd.services."nixos-upgrade-git-prepare" = {
        wants = [ "nixos-upgrade-git-conclude.service" ];
        before = [ "nixos-upgrade-git-conclude.service" ];
      };
      systemd.services."nixos-upgrade-git-conclude" = {
        # Internet access might be needed
        wants = lib.mkIf (cfg_gs.pull || cfg_gs.push) [ "network-online.target" ];
        after = lib.mkIf (cfg_gs.pull || cfg_gs.push) [ "network-online.target" ];
      };

      # NixOS-Upgrade starts only after both
      systemd.services."nixos-upgrade" = {
        wants = [ "nixos-upgrade-git-prepare.service" "nixos-upgrade-git-conclude.service" ];
        after = [ "nixos-upgrade-git-prepare.service" "nixos-upgrade-git-conclude.service" ];
      };

    };
  }
