{ config, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; {

    # PowerDevil: Power manager for Plasma
    programs.plasma.powerdevil = {
      general.pausePlayersOnSuspend = (utils.mkDefault) true; # Pause players when suspending

      # When connected to power
      AC = {

        # Behaviour
        powerButtonAction = (utils.mkDefault) "sleep"; # action when clicking the powerbutton
        powerProfile = (utils.mkDefault) "performance"; # Power profile
        whenSleepingEnter = (utils.mkDefault) "standbyThenHibernate"; # Sleep, then hibernate

        # Laptop lid behaviour
        whenLaptopLidClosed = (utils.mkDefault) "sleep"; # Action when the lid is closed
        inhibitLidActionWhenExternalMonitorConnected = (
          (utils.mkDefault) true # When connected to a external monitor, closing the lid does nothing
        );

        # Actions before an end
        displayBrightness = (utils.mkDefault) 80; # In %
        dimDisplay = {
          enable = (utils.mkDefault) true; # Dim the screen
          idleTimeout = (utils.mkDefault) ( # 30s before screen goes off
            config.programs.plasma.powerdevil.AC.turnOffDisplay.idleTimeout - 30
          );
        };
        turnOffDisplay = {
          idleTimeout = (utils.mkDefault) (10 * 60); # 10min
          idleTimeoutWhenLocked = (utils.mkDefault) (1 * 60); # 1min
        };
        autoSuspend = {
          action = (utils.mkDefault) "sleep"; # Keep RAM powered
          idleTimeout = (utils.mkDefault) (30 * 60); # 30min
        };

      };

      # When on battery
      batteryLevels = {
        lowLevel = (utils.mkDefault) 20; # Level in % considered to be low
        criticalLevel = (utils.mkDefault) 3; # Level in % considered to be critical
        criticalAction = (utils.mkDefault) "hibernate"; # Action when in critical level
      };
      battery = {

        # Behaviour
        powerButtonAction = (utils.mkDefault) "sleep"; # action when clicking the powerbutton
        powerProfile = (utils.mkDefault) "balanced"; # Power profile
        whenSleepingEnter = (utils.mkDefault) "standbyThenHibernate"; # Sleep, then hibernate

        # Laptop lid behaviour
        whenLaptopLidClosed = (utils.mkDefault) "sleep"; # Action when the lid is closed
        inhibitLidActionWhenExternalMonitorConnected = (
          (utils.mkDefault) true # When connected to a external monitor, closing the lid does nothing
        );

        # Actions before an end
        displayBrightness = (utils.mkDefault) 60; # In %
        dimDisplay = {
          enable = (utils.mkDefault) true; # Dim the screen
          idleTimeout = (utils.mkDefault) ( # 30s before screen goes off
            config.programs.plasma.powerdevil.AC.turnOffDisplay.idleTimeout - 30
          );
        };
        turnOffDisplay = {
          idleTimeout = (utils.mkDefault) (5 * 60); # 5min
          idleTimeoutWhenLocked = (utils.mkDefault) 30; # 30s
        };
        autoSuspend = {
          action = (utils.mkDefault) "sleep"; # Keep RAM powered
          idleTimeout = (utils.mkDefault) (15 * 60); # 15min
        };

      };
      lowBattery = {

        # Behaviour
        powerButtonAction = (utils.mkDefault) "sleep"; # action when clicking the powerbutton
        powerProfile = (utils.mkDefault) "powerSaving"; # Power profile
        whenSleepingEnter = (utils.mkDefault) "standbyThenHibernate"; # Sleep, then hibernate

        # Laptop lid behaviour
        whenLaptopLidClosed = (utils.mkDefault) "sleep"; # Action when the lid is closed
        inhibitLidActionWhenExternalMonitorConnected = (
          (utils.mkDefault) true # When connected to a external monitor, closing the lid does nothing
        );

        # Actions before an end
        displayBrightness = (utils.mkDefault) 20; # In %
        dimDisplay = {
          enable = (utils.mkDefault) true; # Dim the screen
          idleTimeout = (utils.mkDefault) ( # 30s before screen goes off
            config.programs.plasma.powerdevil.AC.turnOffDisplay.idleTimeout - 30
          );
        };
        turnOffDisplay = {
          idleTimeout = (utils.mkDefault) (2 * 60); # 2min
          idleTimeoutWhenLocked = (utils.mkDefault) 30; # 30s
        };
        autoSuspend = {
          action = (utils.mkDefault) "sleep"; # Keep RAM powered
          idleTimeout = (utils.mkDefault) (10 * 60); # 10min
        };

      };

    };

  };
}
