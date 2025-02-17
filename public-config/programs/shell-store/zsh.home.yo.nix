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
              dg() {
                local generations;
                for command in "$@"; do
                  if [[ $command =~ ^[0-9]+$ ]]; then
                    generations="$generations $command";
                  fi;
                done;
                echo "";
                echo "Deleting system generations...";
                eval "sudo nix-env --delete-generations $generations --profile ${profilePath}";
                echo "";
                echo "Deleting ALL home-manager generations...";
                home-manager expire-generations "-0 day";
              };
              dg
            ''
          );

          collectGarbageCommand = "nix-collect-garbage";

          nxCommand = (
            utils.replaceStr "\n" "" ''
              nx() {
                case $1 in
                  "boot")
                    ${rebuildSystemCommand "boot"};
                  ;;
                  "test")
                    ${rebuildSystemCommand "test"};
                  ;;
                  "switch")
                    ${rebuildSystemCommand "switch"};
                  ;;
                  "build-vm")
                    ${rebuildSystemCommand "build-vm"};
                  ;;
                  "home")
                    ${rebuildHomeCommand};
                  ;;
                  "list")
                    ${list "${systemProfile.name}"};
                  ;;
                  "listsys")
                    ${list "${upgradeProfile.name}"};
                  ;;
                  "delgen")
                    ${deleteGenerationsCommand "${systemProfile.path}"} $@;
                  ;;
                  "delgensys")
                    ${deleteGenerationsCommand "${upgradeProfile.path}"} $@;
                  ;;
                  "cg")
                    ${collectGarbageCommand};
                  ;;
                esac;
              };
              nx
            ''
          );

        in {
          "nx" = nxCommand;
        }
      );
      
    };

  });
}
