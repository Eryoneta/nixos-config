{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # NX Function
  config.modules."nx-command" = {
    attr.configurationLimit = config.modules."default-auto-upgrade".attr.configurationLimit;
    attr.systemUpgradeProfileName = config.modules."default-auto-upgrade".attr.systemUpgradeProfileName;
    tags = [ "yo" ];
    setup = { attr }: {
      home = { userDev, auto-upgrade-pkgs, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.zsh.initExtra = (
          let

            version = "v1.1.0"; # Should be changed at each modification
            systemProfile = {
              name = "system";
              path = "/nix/var/nix/profiles/${systemProfile.name}";
              flakePath = "path:${userDev.configDevFolder}#${userDev.host.name}"; # "path:" = Ignores Git repository
              preStart = "";
            };
            upgradeProfile = {
              name = "${attr.systemUpgradeProfileName}";
              path = "/nix/var/nix/profiles/system-profiles/${upgradeProfile.name}";
              flakePath = "git+file://${userDev.configFolder}?submodules=1#${userDev.host.name}";
              # Notice: The flag "submodules=1" is necessary to make the flake see Git submodules
              # TODO: (Config/AutoUpgrade) Remove once submodules are supported by default
              preStart = (
                let
                  profilePath = upgradeProfile.path;
                  configurationLimit = attr.configurationLimit;
                in "sudo nix-env --delete-generations +${builtins.toString (configurationLimit - 1)} --profile ${profilePath} || true"
              );
            };

            versionCommand = "echo ${version}"; # Useful for telling if the terminal got the latest one or not

            rebuildSystemCommand = rebuildMode: (
              let
                promptSudo = "sudo ls /dev/null > /dev/null 2>&1"; # Makes the sudo prompt appear before (If later, nom hides the prompt)
                args = "--use-remote-sudo --show-trace --print-build-logs --verbose";
                nomOutput = "|& nom"; # nix-output-monitor
                rebuildSystem = (utils.replaceStr "\n" "" ''
                  nx-rs() {
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
                  nx-rs
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
                nx-ufl() {
                  echo "Updating flake.lock...";
                  nix flake update ${inputs} --flake "${configFolderPath}" --commit-lock-file;
                  cd "${configFolderPath}";
                  if [[ $(git diff --name-only HEAD HEAD~1) == "flake.lock" ]]; then
                    git commit --amend --no-edit --author="NixOS AutoUpgrade <nixos@${userDev.host.name}>";
                  fi;
                  cd -;
                };
                nx-ufl
              '')
            );

            downgradeSystemCommand = (
              let
                args = "--rollback --use-remote-sudo --show-trace --print-build-logs --verbose";
              in "sudo nixos-rebuild switch --flake \"${systemProfile.flakePath}\" ${args}"
            );

            listGenerationsCommand = (
              utils.replaceStr "\n" "" ''
                nx-lg() {
                  local profileNameArg;
                  if [[ $2 =~ ^sys$ ]]; then
                    profileNameArg="--profile-name ${upgradeProfile.name}";
                  else
                    profileNameArg="";
                  fi;
                  eval "nixos-rebuild list-generations $profileNameArg";
                };
                nx-lg
              ''
            );

            deleteGenerationsCommand = (
              let
                promptSudo = "sudo ls /dev/null > /dev/null 2>&1"; # Makes the sudo prompt appear before
                mkDeleteCommand = user: profile: isSystemPath: ''
                  echo "Deleting ALL ${profile} generations from ${user}...";
                  sudo nix-env --delete-generations +1 --profile ${
                    if (isSystemPath) then (
                      "/nix/var/nix/profiles/per-user/${user}/${profile}"
                    ) else "/home/${user}/.local/state/nix/profiles/${profile}"
                  };
                  echo "";
                '';
                # Note: Yikes! There is A LOT of profiles around!
                #   "home-manager expire-generations -d" = Deletes from "/home/USER/.local/state/nix/profiles/home-manager"
                #   "nix-env --delete-generations +1" = Deletes from "/home/USER/.local/state/nix/profiles/profile"
                #   "sudo home-manager expire-generations -d" = Deletes from "/nix/var/nix/profiles/per-user/root/home-manager"
                #   "sudo nix-env --delete-generations +1" = Deletes from "/nix/var/nix/profiles/per-user/root/profile"
                #   There is also "/nix/var/nix/profiles/system/" and "/nix/var/nix/profiles/system-profiles/PROFILE"
                #   Also channels, in "/nix/var/nix/profiles/per-user/root/channels"
                # It is worryingly easy to accumulate a lot of generations! A lot of wasted space! Specially with home-manager generations!
                #   This is unsustainable
              in (utils.replaceStr "\n" "" ''
                nx-dg() {
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
                  ${promptSudo};
                  echo "";
                  echo "Deleting system generations...";
                  eval "sudo nix-env --delete-generations $generations --profile $profilePath";
                  echo "";
                  ${mkDeleteCommand "yo" "home-manager" false}
                  ${mkDeleteCommand "yo" "profile" false}
                  ${mkDeleteCommand "eryoneta" "home-manager" false}
                  ${mkDeleteCommand "eryoneta" "profile" false}
                  ${mkDeleteCommand "root" "home-manager" true}
                  ${mkDeleteCommand "root" "profile" true}
                  ${mkDeleteCommand "root" "channels" true}
                };
                nx-dg
              '')
            );
            # Note: It also deletes all home-manager/nix generations from the current user and root!

            collectGarbageCommand = (
              "sudo nix-collect-garbage"
            );

            nxCommand = (
              # Note: Everything is collapsed into a single line!
              utils.replaceStr "\n" "" ''
                nx() {
                  case $1 in
                    "version")
                      ${versionCommand};
                    ;;
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
              ''
            );

          in ''
            # NX Command
            ${nxCommand}
          ''
        );

      };
    };
  };

}
