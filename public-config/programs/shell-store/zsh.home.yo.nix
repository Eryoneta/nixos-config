{ config, user, ... }@args: with args.config-utils; {
  config = with config.profile.programs.zsh; {

    # ZSH: Shell
    programs.zsh = {

      # Aliases
      shellAliases = (
        let
          rebuildSystemCommand = rebuildMode: (
            let
              promptSudo = "sudo ls /dev/null > /dev/null 2>&1";
              nixosRebuild = "sudo nixos-rebuild";
              flakePath = "path:${user.configDevFolder}#${user.name}@${user.host.name}";
              args = "--use-remote-sudo --show-trace --print-build-logs --verbose";
              nomOutput = "|& nom"; # nix-output-monitor
            in "${promptSudo} && ${nixosRebuild} ${rebuildMode} --flake ${flakePath} ${args} ${nomOutput}"
          );
          rebuildHomeCommand = (
            let
              homeManagerRebuild = "home-manager switch";
              flakePath = "path:${user.configDevFolder}#${user.name}@${user.host.name}";
              args = "--print-build-logs --verbose";
            in "${homeManagerRebuild} --flake ${flakePath} ${args}"
          );
          deleteGenerationsCommand = profilePath: (
            utils.joinStr " " [
              "f() {"
                "local generations;"
                ''for command in "$@"; do''
                  ''generations="$generations $command"''
                "done;"
                ''echo "";''
                ''echo "Deleting system generations...";''
                ''eval "sudo nix-env --delete-generations $generations --profile ${profilePath};"''
                ''echo "";''
                ''echo "Deleting ALL home-manager generations...";''
                ''home-manager expire-generations "-0 day";''
              "};f"
            ]
          );
        in {
          # Rebuild
          "nx-boot" = (rebuildSystemCommand "boot");
          "nx-test" = (rebuildSystemCommand "test");
          "nx-switch" = (rebuildSystemCommand "switch");
          "nx-home" = (rebuildHomeCommand);
          # Generations
          "nx-list" = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
          "nx-list2" = ''cat /boot/grub/grub.cfg | sed -n "s/^menuentry \"NixOS - \(.*\)\" --class nixos .*$/\1/p"'';
          "nx-delgen" = (deleteGenerationsCommand "/nix/var/nix/profiles/system");
          "nx-delsysgen" = (deleteGenerationsCommand "/nix/var/nix/profiles/system-profiles/System_Updates");
          # Garbage
          "nx-trim" = "nix-collect-garbage";
        }
      );
      
    };

  };
}
