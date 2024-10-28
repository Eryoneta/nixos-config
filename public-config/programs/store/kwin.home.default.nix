{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; {

    # KWin Window manager for Plasma
    programs.plasma.kwin = {

      # Windows
      borderlessMaximizedWindows = (utils.mkDefault) false; # Show borders even when full size
      titlebarButtons = {
        left = (utils.mkDefault) [
          "keep-above-windows"
        ];
        right = (utils.mkDefault) [
          "minimize"
          "maximize"
          "close"
        ];
      };

      # Barriers
      cornerBarrier = (utils.mkDefault) false; # Do not stop cursor from crossing screens at corners
      edgeBarrier = (utils.mkDefault) 0; # Extra space between screens

      # Virtual desktops
      virtualDesktops.names = (utils.mkDefault) [ # List of virtual desktops
        "Main Desktop"
        "Secondary Desktop"
      ];

      # Effects
      effects = {
        desktopSwitching.animation = (utils.mkDefault) "slide"; # Virtual desktop animation
        minimization.animation = (utils.mkDefault) "squash"; # Minimzation animation
        windowOpenClose.animation = (utils.mkDefault) "glide"; # Open/Close window animation
        shakeCursor.enable = (utils.mkDefault) true; # Shaking the cursor increase its size
        dimAdminMode.enable = (utils.mkDefault) true; # Dim screen when requesting root privileges
        dimInactive.enable = (utils.mkDefault) true; # Dim inactive screens
      };

      # Night light
      nightLight = {
        enable = (utils.mkDefault) true;
        mode = (utils.mkDefault) "times"; # Chenge by time
        temperature = {
          day = (utils.mkDefault) 4500; # Day light temperature
          night = (utils.mkDefault) 3500; # Night light temperature
        };
        time = {
          morning = (utils.mkDefault) "08:00"; # Morning time
          evening = (utils.mkDefault)  "20:00"; # Night time
        };
        transitionTime = (utils.mkDefault) 30; # Time in minutes for the transition
      };

    };

  };
}
