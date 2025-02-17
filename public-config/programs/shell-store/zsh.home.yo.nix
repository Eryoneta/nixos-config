{ lib, config, user, ... }@args: with args.config-utils; {
  config = with config.profile.programs.zsh; (lib.mkIf (options.enabled) {

    # ZSH: Shell
    programs.zsh = {

      # Aliases
      shellAliases = (
        let
          systemProfile = rec {
            name = "system";
            path = "/nix/var/nix/profiles/${name}";
          };
          upgradeProfile = rec {
            name = "System_Upgrades";
            path = "/nix/var/nix/profiles/system-profiles/${name}";
          };

          rebuildSystemCommand = rebuildMode: (
            let
              promptSudo = "sudo ls /dev/null > /dev/null 2>&1"; # Makes the sudo prompt appear before (If later, nom hides the prompt)
              nixosRebuild = "sudo nixos-rebuild";
              flakePath = "path:${user.configDevFolder}#${user.name}@${user.host.name}"; # "path:" = Ignores Git repository
              args = "--use-remote-sudo --show-trace --print-build-logs --verbose";
              nomOutput = "|& nom"; # nix-output-monitor
            in "${promptSudo} && ${nixosRebuild} ${rebuildMode} --flake ${flakePath} ${args} ${nomOutput}"
          );

          rebuildHomeCommand = (
            let
              homeManagerRebuild = "home-manager";
              rebuildMode = "switch";
              flakePath = "path:${user.configDevFolder}#${user.name}@${user.host.name}"; # "path:" = Ignores Git repository
              args = "--print-build-logs --verbose";
            in "${homeManagerRebuild} ${rebuildMode} --flake ${flakePath} ${args}"
          );

          list = profileName: (
            let
              nixosRebuild = "nixos-rebuild";
              profile = if(profileName != "") then "--profile-name ${profileName}" else "";
            in "${nixosRebuild} list-generations ${profile}"
          );

          deleteGenerationsCommand = profilePath: (
            utils.replaceStr "\n" "" ''
              f() {
                local generations;
                for command in "$@"; do
                  generations="$generations $command"
                done;
                echo "";
                echo "Deleting system generations...";
                eval "sudo nix-env --delete-generations $generations --profile ${profilePath};"
                echo "";
                echo "Deleting ALL home-manager generations...";
                home-manager expire-generations "-0 day";
              };f
            ''
          );

          collectGarbageCommand = "nix-collect-garbage";

        in {
          # Rebuild
          "nx-boot" = (rebuildSystemCommand "boot");
          "nx-test" = (rebuildSystemCommand "test");
          "nx-switch" = (rebuildSystemCommand "switch");
          "nx-build-vm" = (rebuildSystemCommand "build-vm");
          "nx-home" = (rebuildHomeCommand);
          # Generations
          "nx-list" = (list "${systemProfile.name}");
          "nx-listsys" = (list "${upgradeProfile.name}");
          "nx-delgen" = (deleteGenerationsCommand "${systemProfile.path}");
          "nx-delgensys" = (deleteGenerationsCommand "${upgradeProfile.path}");
          # Garbage
          "nx-cg" = (collectGarbageCommand);
          # TODO: (ZSH) Replace "nx-*" with "nx *"
        }
      );
      
    };

  });
}
