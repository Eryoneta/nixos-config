{ lib, config, userDev, auto-upgrade-pkgs, ... }@args: with args.config-utils; {
  config = with config.profile.programs.zsh; (lib.mkIf (options.enabled) {

    # ZSH: Shell
    programs.zsh = {

      # Aliases
      shellAliases = (
        let
          systemProfile = {
            name = "system";
            path = "/nix/var/nix/profiles/${systemProfile.name}";
            flakePath = "path:${userDev.configDevFolder}#${userDev.name}@${userDev.host.name}"; # "path:" = Ignores Git repository
            preStart = "";
          };
          upgradeProfile = {
            name = "System_Upgrades";
            path = "/nix/var/nix/profiles/system-profiles/${upgradeProfile.name}";
            flakePath = "git+file://${userDev.configFolder}?submodules=1#${userDev.name}@${userDev.host.name}";
            # Notice: The flag "submodules=1" is necessary to make the flake see Git submodules
            # TODO: (Config/AutoUpgrade) Remove once submodules are supported by default
            preStart = (
              let
                profilePath = upgradeProfile.path;
                configurationLimit = 8; # Needs to be the same as in "config.system.autoUpgrade.alterProfile.configurationLimit"!
              in "sudo nix-env --delete-generations +${builtins.toString (configurationLimit - 1)} --profile ${profilePath} || true"
            );
          };

          rebuildSystemCommand = rebuildMode: (
            let
              promptSudo = "sudo ls /dev/null > /dev/null 2>&1"; # Makes the sudo prompt appear before (If later, nom hides the prompt)
              args = "--use-remote-sudo --show-trace --print-build-logs --verbose";
              nomOutput = "|& nom"; # nix-output-monitor
              rebuildSystem = (utils.replaceStr "\n" "" ''
                rs() {
                  local profileNameArg;
                  local flakePathArg;
                  if [[ $2 =~ ^sys$ ]]; then
                    profileNameArg="--profile-name ${upgradeProfile.name}";
                    flakePathArg="--flake \"${upgradeProfile.flakePath}\"";
                    preStart="${upgradeProfile.preStart}";
                  else
                    profileNameArg="--profile-name ${systemProfile.name}";
                    flakePathArg="--flake \"${systemProfile.flakePath}\"";
                    preStart="${systemProfile.preStart}";
                  fi;
                  eval "$preStart; sudo nixos-rebuild ${rebuildMode} $flakePathArg $profileNameArg ${args} ${nomOutput}";
                };
                rs
              '');
            in "${promptSudo} && ${rebuildSystem}"
          );

          rebuildHomeCommand = (
            let
              args = "--flake \"${systemProfile.flakePath}\" --print-build-logs --verbose";
            in "home-manager switch ${args}"
          );

          upgradeSystemCommand = (
            let
              inputs = (builtins.toString auto-upgrade-pkgs);
              configFolderPath = userDev.configFolder;
              # Important note: This whole command should be equivalent as set by "modules/nixos-modules/auto-upgrade-update-flake-lock.nix"!
            in (utils.replaceStr "\n" "" ''
              ufl() {
                echo "Updating flake.lock...";
                nix flake update ${inputs} --flake "${configFolderPath}" --commit-lock-file;
                cd "${configFolderPath}";
                if [[ $(git diff --name-only HEAD HEAD~1) == "flake.lock" ]]; then
                  git commit --amend --no-edit --author="NixOS AutoUpgrade <nixos@${userDev.host.name}>";
                fi;
                cd -;
              };
              ufl
            '')
          );

          downgradeSystemCommand = (
            let
              args = "--rollback --use-remote-sudo --show-trace --print-build-logs --verbose";
            in "sudo nixos-rebuild switch --flake \"${systemProfile.flakePath}\" ${args}"
          );

          listGenerationsCommand = (
            utils.replaceStr "\n" "" ''
              lg() {
                local profileNameArg;
                if [[ $2 =~ ^sys$ ]]; then
                  profileNameArg="--profile-name ${upgradeProfile.name}";
                else
                  profileNameArg="";
                fi;
                eval "nixos-rebuild list-generations $profileNameArg";
              };
              lg
            ''
          );

          deleteGenerationsCommand = (
            utils.replaceStr "\n" "" ''
              dg() {
                local profilePath;
                if [[ $2 =~ ^sys$ ]]; then
                  profilePath=${upgradeProfile.path};
                else
                  profilePath=${systemProfile.path};
                fi;
                local generations;
                for command in "$@"; do
                  if [[ $command =~ ^[0-9]+$ ]]; then
                    generations="$generations $command";
                  fi;
                done;
                echo "";
                echo "Deleting system generations...";
                eval "sudo nix-env --delete-generations $generations --profile $profilePath";
                echo "";
                echo "Deleting ALL home-manager generations from user...";
                home-manager expire-generations -d;
                echo "";
                echo "Deleting ALL home-manager generations from root...";
                sudo home-manager expire-generations -d;
                echo "";
                echo "Deleting ALL nix generations from user...";
                nix-env --delete-generations +1;
                echo "";
                echo "Deleting ALL nix generations from root...";
                sudo nix-env --delete-generations +1;
                echo "";
              };
              dg
            ''
          ); # Note: It also deletes all home-manager/nix generations from the current user and root!

          collectGarbageCommand = ( # Should delete from both system and user profiles
            utils.replaceStr "\n" "" ''
              sudo nix-collect-garbage;
              nix-collect-garbage;
            ''
          );

          nxCommand = (
            # Note: Everything is collapsed into a single line
            utils.replaceStr "\n" "" ''
              nx() {
                case $1 in
                  "boot")
                    ${rebuildSystemCommand "boot"} $@;
                  ;;
                  "test")
                    ${rebuildSystemCommand "test"} $@;
                  ;;
                  "switch")
                    ${rebuildSystemCommand "switch"} $@;
                  ;;
                  "build-vm")
                    ${rebuildSystemCommand "build-vm"} $@;
                  ;;
                  "home")
                    ${rebuildHomeCommand};
                  ;;
                  "upgrade")
                    ${upgradeSystemCommand};
                  ;;
                  "rollback")
                    ${downgradeSystemCommand};
                  ;;
                  "list")
                    ${listGenerationsCommand} $@;
                  ;;
                  "degen")
                    ${deleteGenerationsCommand} $@;
                  ;;
                  "trim")
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
