# Notifier for Garbage Collector
/*
  - Creates a notification for every garbage collection made
    - Great as a  warning before the big operation
  - Uses "libnotify"
  - Depends on the option set by "nixpkgs/nixos/modules/services/misc/nix-gc.nix"
*/
{ config, pkgs, lib, ... }:
  let
    cfg = config.nix.gc;
    cfg_n = config.nix.gc.notifier;
  in {

    options = {
      nix.gc.notifier = {

        enable = lib.mkEnableOption ''
          Enables a notifier to appear before and after a garbage collection.
        '';

        systemUser = lib.mkOption {
          type = lib.types.str;
          description = "The system user to execute 'notify-send' commands.";
          default = "root";
        };

        informStart = {
          show = lib.mkOption {
            type = lib.types.bool;
            description = "Shows a notification when garbage collect starts.";
            default = true;
          };
          time = lib.mkOption {
            type = lib.types.either (lib.types.ints.between 1 86400) (lib.types.enum [ "infinite" ]);
            description = ''
              Time in seconds to show the notification.

              Can be either a number between 1 and 86400, or "infinite"
            '';
            default = 15;
          };
        };

        informConclusion = {
          show = lib.mkOption {
            type = lib.types.bool;
            description = "Shows a notification when garbage collect ends, informing success or failure.";
            default = true;
          };
          time = lib.mkOption {
            type = lib.types.either (lib.types.ints.between 1 86400) (lib.types.enum [ "infinite" ]);
            description = ''
              Time in seconds to show the notification.

              Can be either a number between 1 and 86400, or "infinite"
            '';
            default = "infinite";
          };
        };

      };
    };

    config = lib.mkIf (cfg.automatic && cfg_n.enable) {

      assertions = [{
        assertion = !(!cfg_n.informStart.show && !cfg_n.informConclusion.show);
        message = ''
          The option 'nix.gc.notifier.enable' requires at least one of 'informStart.show' or 'informConclusion.show' to be set.
        '';
      }];

      systemd = (
        let
          mkScript = {text, icon, timing}: ''
            # Interrupts if there is an error or undefined variable
            set -eu
            # Loads access
            export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/''${UID}/bus"
            # Send notification
            notify-send "Nix Garbage Collector" \
              "${text}" \
              --icon "${icon}" \
              --urgency "${timing.urgency}" \
              --expire-time ${timing.expireTime}
          '';
          mkTiming = time: {
            urgency = if ((builtins.typeOf time) == "string" && time == "infinite") then "critical" else "normal";
            expireTime = (builtins.toString (
              (if ((builtins.typeOf time) == "int" && time >= 1) then time else 1) * 1000) # Seconds -> Miliseconds
            );
          };
        in {

          # Notify garbage collection start
          services."garbage-collector-notify-start" = lib.mkIf (cfg_n.informStart.show) {
            serviceConfig = {
              "Type" = "oneshot";
              "User" = cfg_n.systemUser;
            };
            path = with pkgs; [
              coreutils
              libnotify
            ];
            script = (mkScript {
              text = "Performing garbage collection...";
              icon = "trash-empty";
              timing = (mkTiming cfg_n.informStart.time);
            });
          };

          # Notify garbage collection success
          services."garbage-collector-notify-success" = lib.mkIf (cfg_n.informConclusion.show) {
            serviceConfig = {
              "Type" = "oneshot";
              "User" = cfg_n.systemUser;
            };
            path = with pkgs; [
              coreutils
              libnotify
            ];
            script = (mkScript {
              text = "Garbage collection was successful";
              icon = "trash-empty";
              timing = (mkTiming cfg_n.informConclusion.time);
            });
          };

          # Notify garbage collection failure
          services."garbage-collector-notify-failure" = lib.mkIf (cfg_n.informConclusion.show) {
            serviceConfig = {
              "Type" = "oneshot";
              "User" = cfg_n.systemUser;
            };
            path = with pkgs; [
              coreutils
              libnotify
            ];
            script = (mkScript {
              text = "Garbage collection failed";
              icon = "script-error";
              timing = (mkTiming cfg_n.informConclusion.time);
            });
          };

          # Nix Garbage Collector calls the services as needed
          services."nix-gc" = {
            wants = (lib.optional (cfg_n.informStart.show) "garbage-collector-notify-start.service");
            after = (lib.optional (cfg_n.informStart.show) "garbage-collector-notify-start.service");
            onSuccess = (lib.optional (cfg_n.informConclusion.show) "garbage-collector-notify-success.service");
            onFailure = (lib.optional (cfg_n.informConclusion.show) "garbage-collector-notify-failure.service");
          };

        }
      );

    };
  }
