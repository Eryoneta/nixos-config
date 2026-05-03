# Notifier for AutoUpgrade
/*
  - Creates a notification for every upgrade made
    - Great for knowing if the upgrade was a success or not
  - Uses "libnotify"
  - Depends on the option set by "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
*/
{ config, pkgs, lib, ... }:
  let
    cfg = config.system.autoUpgrade;
    cfg_n = config.system.autoUpgrade.notifier;
  in {

    options = {
      system.autoUpgrade.notifier = {

        enable = lib.mkEnableOption ''
          Enables a notifier to appear before and after a NixOS upgrade.
        '';

        systemUser = lib.mkOption {
          type = lib.types.str;
          description = "The system user to execute 'notify-send' commands.";
          default = "root";
        };

        informStart = {

          show = lib.mkOption {
            type = lib.types.bool;
            description = "Show notification when a upgrade starts.";
            default = true;
          };

          time = lib.mkOption {
            type = (lib.types.either (lib.types.ints.between 1 86400) (lib.types.enum [ "infinite" ]));
            description = ''
              Time in seconds to show the notification.

              Can be either a number between 1 and 86400, or "infinite"
            '';
            default = 15;
          };

          promptConfirmation = lib.mkOption {
            type = lib.types.bool;
            description = ''
              Instead of a notification, it's a confirmation prompt.

              This allows to cancel the upgrade, if desired.
            '';
            default = false;
          };

        };

        informConclusion = {

          show = lib.mkOption {
            type = lib.types.bool;
            description = "Shows a notification when a upgrade ends, informing success or failure.";
            default = true;
          };

          time = lib.mkOption {
            type = (lib.types.either (lib.types.ints.between 1 86400) (lib.types.enum [ "infinite" ]));
            description = ''
              Time in seconds to show the notification.

              Can be either a number between 1 and 86400, or "infinite"
            '';
            default = "infinite";
          };

        };

      };
    };

    config = lib.mkIf (cfg.enable && cfg_n.enable) {

      assertions = [{
        assertion = !(!cfg_n.informStart.show && !cfg_n.informConclusion.show);
        message = ''
          The option 'system.autoUpgrade.notifier.enable' requires at least one of 'informStart.show' or 'informConclusion.show' to be set.
        '';
      }];

      systemd = (
        let
          mkScript = {text, icon, timing, promptConfirmation ? false}: ''
            # Interrupts if there is an error or undefined variable
            set -eu;
            # Loads access
            export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/''${UID}/bus";
            # Send notification
            ${if (promptConfirmation) then (''
              # Prompt for upgrade
              action=$(notify-send "NixOS Upgrade" \
                "Execute system upgrade?" \
                --icon "${icon}" \
                --action "1=Execute" \
                --action "0=Ignore" \
                --urgency "critical");
              # Action
              if [[ $action -eq 1 ]]; then
                notify-send "NixOS Upgrade" \
                  "${text}" \
                  --icon "${icon}" \
                  --urgency "${timing.urgency}" \
                  --expire-time ${timing.expireTime};
              else
                notify-send "NixOS Upgrade" \
                  "Upgrade cancelled" \
                  --icon "info";
                exit 1; # Trigger a failure. This should cancel nixos-upgrade
              fi
              exit 0; # Continue
            '') else (''
              notify-send "NixOS Upgrade" \
                "${text}" \
                --icon "${icon}" \
                --urgency "${timing.urgency}" \
                --expire-time ${timing.expireTime};
            '')}
          '';
          mkTiming = time: {
            urgency = (if ((builtins.typeOf time) == "string" && time == "infinite") then "critical" else "normal");
            expireTime = (builtins.toString (
              (if ((builtins.typeOf time) == "int" && time >= 1) then time else 1) * 1000) # Seconds -> Miliseconds
            );
          };
        in {

          # Notify upgrade start
          services."nixos-upgrade-notify-start" = lib.mkIf (cfg_n.informStart.show) {
            serviceConfig = {
              "Type" = "oneshot";
              "User" = cfg_n.systemUser;
            };
            path = with pkgs; [
              coreutils
              libnotify
            ];
            script = (mkScript {
              text = "Performing system upgrade...\nIt should be available in the next boot";
              icon = "system-upgrade";
              timing = (mkTiming cfg_n.informStart.time);
              promptConfirmation = cfg_n.informStart.promptConfirmation;
            });
          };

          # Notify upgrade success
          services."nixos-upgrade-notify-success" = lib.mkIf (cfg_n.informConclusion.show) {
            serviceConfig = {
              "Type" = "oneshot";
              "User" = cfg_n.systemUser;
            };
            path = with pkgs; [
              coreutils
              libnotify
            ];
            script = (mkScript {
              text = "The system upgrade was successful";
              icon = "system-upgrade";
              timing = (mkTiming cfg_n.informConclusion.time);
            });
          };

          # Notify upgrade failure
          services."nixos-upgrade-notify-failure" = lib.mkIf (cfg_n.informConclusion.show) {
            serviceConfig = {
              "Type" = "oneshot";
              "User" = cfg_n.systemUser;
            };
            path = with pkgs; [
              coreutils
              libnotify
            ];
            script = (mkScript {
              text = "The system upgrade failed";
              icon = "script-error";
              timing = (mkTiming cfg_n.informConclusion.time);
            });
          };

          # NixOS-Upgrade calls the services as needed
          services."nixos-upgrade" = {
            requires = (lib.optional (cfg_n.informStart.show) "nixos-upgrade-notify-start.service");
            after = (lib.optional (cfg_n.informStart.show) "nixos-upgrade-notify-start.service");
            onSuccess = (lib.optional (cfg_n.informConclusion.show) "nixos-upgrade-notify-success.service");
            onFailure = (lib.optional (cfg_n.informConclusion.show) "nixos-upgrade-notify-failure.service");
          };

        }
      );

    };
  }
