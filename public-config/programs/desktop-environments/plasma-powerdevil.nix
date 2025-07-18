{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # PowerDevil: Power manager for Plasma
  config.modules."plasma-powerdevil" = {
    tags = config.modules."plasma".tags;
    setup = {
      nixos = { # (NixOS Module)

        # Time after sleep, before hibernation
        config.systemd.sleep.extraConfig = (utils.mkDefault) ''
          HibernateDelaySec=4h
        '';

      };
      home = { config, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.powerdevil = { # (plasma-manager option)

          # General
          general.pausePlayersOnSuspend = (utils.mkDefault) true; # Pause players when suspending
          batteryLevels = {
            lowLevel = (utils.mkDefault) 20; # Level in % considered to be low
            criticalLevel = (utils.mkDefault) 3; # Level in % considered to be critical
            criticalAction = (utils.mkDefault) "hibernate"; # Action when in critical level
          };

          # Behaviour
          # Action when clicking the powerbutton
          AC.powerButtonAction = (utils.mkDefault) "sleep"; 
          battery.powerButtonAction = (utils.mkDefault) "sleep";
          lowBattery.powerButtonAction = (utils.mkDefault) "sleep";
          # Power profile
          AC.powerProfile = (utils.mkDefault) "performance"; 
          battery.powerProfile = (utils.mkDefault) "balanced";
          lowBattery.powerProfile = (utils.mkDefault) "powerSaving";
          # What "sleep" means
          AC.whenSleepingEnter = (utils.mkDefault) "standbyThenHibernate"; 
          battery.whenSleepingEnter = (utils.mkDefault) "standbyThenHibernate";
          lowBattery.whenSleepingEnter = (utils.mkDefault) "standbyThenHibernate";

          # Laptop lid behaviour
          # Action when the lid is closed
          AC.whenLaptopLidClosed = (utils.mkDefault) "sleep";
          battery.whenLaptopLidClosed = (utils.mkDefault) "sleep";
          lowBattery.whenLaptopLidClosed = (utils.mkDefault) "sleep";
          # When connected to a external monitor, closing the lid does nothing
          AC.inhibitLidActionWhenExternalMonitorConnected = (utils.mkDefault) true;
          battery.inhibitLidActionWhenExternalMonitorConnected = (utils.mkDefault) true;
          lowBattery.inhibitLidActionWhenExternalMonitorConnected = (utils.mkDefault) true;

          # Actions before an end
          # Brightness in %
          AC.displayBrightness = (utils.mkDefault) 80;
          battery.displayBrightness = (utils.mkDefault) 60;
          lowBattery.displayBrightness = (utils.mkDefault) 20;
          # Dim the screen
          AC.dimDisplay = {
            enable = (utils.mkDefault) true;
            idleTimeout = (utils.mkDefault) (with config.programs.plasma.powerdevil; (
              AC.turnOffDisplay.idleTimeout - 30 # 30s before screen goes off
            ));
          };
          battery.dimDisplay = {
            enable = (utils.mkDefault) true; # Dim the screen
            idleTimeout = (utils.mkDefault) (with config.programs.plasma.powerdevil; (
              battery.turnOffDisplay.idleTimeout - 20 # 20s before screen goes off
            ));
          };
          lowBattery.dimDisplay = {
            enable = (utils.mkDefault) true; # Dim the screen
            idleTimeout = (utils.mkDefault) (with config.programs.plasma.powerdevil; (
              lowBattery.turnOffDisplay.idleTimeout - 10 # 10s before screen goes off
            ));
          };
          # Turn the display off
          AC.turnOffDisplay = {
            idleTimeout = (utils.mkDefault) (6 * 60); # 6min
            idleTimeoutWhenLocked = (utils.mkDefault) (1 * 60); # 1min
          };
          battery.turnOffDisplay = {
            idleTimeout = (utils.mkDefault) (5 * 60); # 5min
            idleTimeoutWhenLocked = (utils.mkDefault) 30; # 30s
          };
          lowBattery.turnOffDisplay = {
            idleTimeout = (utils.mkDefault) (2 * 60); # 2min
            idleTimeoutWhenLocked = (utils.mkDefault) 20; # 20s
          };
          # Suspend
          AC.autoSuspend = {
            action = (utils.mkDefault) "sleep"; # Keep RAM powered
            idleTimeout = (utils.mkDefault) (30 * 60); # 30min
          };
          battery.autoSuspend = {
            action = (utils.mkDefault) "sleep"; # Keep RAM powered
            idleTimeout = (utils.mkDefault) (15 * 60); # 15min
          };
          lowBattery.autoSuspend = {
            action = (utils.mkDefault) "sleep"; # Keep RAM powered
            idleTimeout = (utils.mkDefault) (10 * 60); # 10min
          };

        };

        # Shortcuts
        config.programs.plasma.shortcuts = { # (plasma-manager option)
          # Actions
          "org_kde_powerdevil"."Sleep" = "Sleep";
          "org_kde_powerdevil"."Hibernate" = "Hibernate";
          "org_kde_powerdevil"."PowerDown" = "Power Down";
          "org_kde_powerdevil"."PowerOff" = "Power Off";
          "org_kde_powerdevil"."powerProfile" = [ "Battery" "Meta+B" ];
          # Keyboard backlight
          "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
          "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
          "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
          # Screen light
          "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
          "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
          "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
          "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
          "org_kde_powerdevil"."Turn Off Screen" = [];
        };

      };
    };
  };

}
