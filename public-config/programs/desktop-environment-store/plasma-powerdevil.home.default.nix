{ config, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; {

    # PowerDevil: Power manager for Plasma
    programs.plasma.powerdevil = {

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
        idleTimeout = (utils.mkDefault) (10 * 60); # 10min
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

  };
}
