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
          };
          upgradeProfile = {
            name = "System_Upgrades";
            path = "/nix/var/nix/profiles/system-profiles/${upgradeProfile.name}";
          };

          rebuildSystemCommand = rebuildMode: (
            let
              promptSudo = "sudo ls /dev/null > /dev/null 2>&1"; # Makes the sudo prompt appear before (If later, nom hides the prompt)
              nixosRebuild = "sudo nixos-rebuild";
              flakePath = "path:${userDev.configDevFolder}#${userDev.name}@${userDev.host.name}"; # "path:" = Ignores Git repository
              args = "--flake \"${flakePath}\" --use-remote-sudo --show-trace --print-build-logs --verbose";
              nomOutput = "|& nom"; # nix-output-monitor
            in "${promptSudo} && ${nixosRebuild} ${rebuildMode} ${args} ${nomOutput}"
          );

          rebuildHomeCommand = (
            let
              homeManagerRebuild = "home-manager";
              rebuildMode = "switch";
              flakePath = "path:${userDev.configDevFolder}#${userDev.name}@${userDev.host.name}"; # "path:" = Ignores Git repository
              args = "--flake \"${flakePath}\" --print-build-logs --verbose";
            in "${homeManagerRebuild} ${rebuildMode} ${args}"
          );

          upgradeSystemCommand = (
            let
              updateFlakeLockCommand = (
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
              rebuildSystemCommand = (
                # Important note: This command should be equivalent as set by "hosts/default/features/auto-upgrade.nix"!
                let
                  promptSudo = "sudo ls /dev/null > /dev/null 2>&1"; # Makes the sudo prompt appear before (If later, nom hides the prompt)
                  nixosRebuild = "sudo nixos-rebuild";
                  rebuildMode = "switch";
                  flakePath = "git+file://${userDev.configFolder}?submodules=1#${userDev.name}@${userDev.host.name}";
                  # Notice: The flake ignores submodules! The flag "submodules=1" is necessary
                  # TODO: (Config/AutoUpgrade) Remove once submodules are supported by default
                  args = "--flake \"${flakePath}\" --profile-name ${upgradeProfile.name} --use-remote-sudo --show-trace --print-build-logs --verbose";
                  nomOutput = "|& nom"; # nix-output-monitor
                in "${promptSudo} && ${nixosRebuild} ${rebuildMode} ${args} ${nomOutput}"
              );
            in "${updateFlakeLockCommand} && ${rebuildSystemCommand}"
            # TODO: (ZSH) Isn't easier to just call nixos-upgrade? Yeah. but it doesn't give outputs... eh
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
            # Note: Everything is collapsed into a single line
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
                  "upgrade")
                    ${upgradeSystemCommand};
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
