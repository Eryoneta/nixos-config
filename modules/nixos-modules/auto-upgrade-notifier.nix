# Notifier for AutoUpgrade
/*
  - Creates a notification for every upgrade made
    - Great for knowing if the upgrade was a success or not
  - Uses "libnotify"
  - Depends on "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
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

        informStart = lib.mkOption {
          type = lib.types.bool;
          description = "Shows a notification when a upgrade starts.";
          default = true;
        };

        informConclusion = lib.mkOption {
          type = lib.types.bool;
          description = "Shows a notification when a upgrade ends, informing success or failure.";
          default = true;
        };

      };
    };

    config = lib.mkIf (cfg.enable && cfg_n.enable) {

      assertions = [{
        assertion = !(!cfg_n.informStart && !cfg_n.informConclusion);
        message = ''
          The option 'system.autoUpgrade.notifier.enable' requires at least one of 'informStart' or 'informConclusion' to be set.
        '';
      }];

      # Notify upgrade start
      systemd.services."nixos-upgrade-notify-start" = lib.mkIf (cfg_n.informStart) {
        serviceConfig = {
          "Type" = "oneshot";
          "User" = cfg_n.systemUser;
        };
        path = with pkgs; [
          coreutils
          libnotify
        ];
        script = ''
          # Interrupts if there is an error or undefined variable
          set -eu
          # Loads access
          export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/''${UID}/bus"
          # Send notification
          notify-send "NixOS Upgrade" \
            "Performing system upgrade...\nIt should be available in the next boot" \
            --urgency "normal" --expire-time 15000 --icon "system-upgrade"
        '';
        # Note: The notification is shown for 15 seconds
      };

      # Notify upgrade success
      systemd.services."nixos-upgrade-notify-success" = lib.mkIf (cfg_n.informConclusion) {
        serviceConfig = {
          "Type" = "oneshot";
          "User" = cfg_n.systemUser;
        };
        path = with pkgs; [
          coreutils
          libnotify
        ];
        script = ''
          # Interrupts if there is an error or undefined variable
          set -eu
          # Loads access
          export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/''${UID}/bus"
          # Send notification
          notify-send "NixOS Upgrade" \
            "The system upgrade was successful" \
            --urgency "critical" --icon "system-upgrade"
        '';
        # Note: The notification is shown until dismissed
      };

      # Notify upgrade success
      systemd.services."nixos-upgrade-notify-failure" = lib.mkIf (cfg_n.informConclusion) {
        serviceConfig = {
          "Type" = "oneshot";
          "User" = cfg_n.systemUser;
        };
        path = with pkgs; [
          coreutils
          libnotify
        ];
        script = ''
          # Interrupts if there is an error or undefined variable
          set -eu
          # Loads access
          export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/''${UID}/bus"
          # Send notification
          notify-send "NixOS Upgrade" \
            "The system upgrade failed" \
            --urgency "critical" --icon "script-error"
        '';
        # Note: The notification is shown until dismissed
      };

      # NixOS-Upgrade calls the services as needed
      systemd.services."nixos-upgrade" = {
        wants = [ "nixos-upgrade-notify-start.service" ];
        after = [ "nixos-upgrade-notify-start.service" ];
        onSuccess = [ "nixos-upgrade-notify-success.service" ];
        onFailure = [ "nixos-upgrade-notify-failure.service" ];
      };

    };
  }
