{ config, ... }@args: with args.config-utils; {

  imports = with args; [
    ./auto-upgrade.nixos.nix
    nixos-modules."link-to-source-config.nix"
    nixos-modules."swap-devices.nix"
    nixos-modules."swapfile-hibernation.nix"
  ];

  config = {

    # Auto-login
    services.displayManager = {
      autoLogin.enable = (utils.mkDefault) false;
      autoLogin.user = args.hostArgs.userDev.username;
    };

    # System AutoUpgrade ("features/auto-upgrade.nix")
    system.autoUpgrade = {
      enable = (utils.mkDefault) true;
    };

    # Link to source configuration ("link-to-source-config.nix")
    system.linkToSourceConfiguration = {
      enable = true;
      configurationPath = args.hostArgs.configFolderNixStore;
    };

    # FSTrim
    services.fstrim = {
      enable = (utils.mkDefault) true;
      interval = "weekly";
    };

    # Swapfile ("swap-devices.nix")
    swap = {
      enable = (utils.mkDefault) true;
      devices = {
        "basicSwap" = {
          device = (utils.mkDefault) "/var/swapfile";
          size = (utils.mkDefault) (4 * 1024);
        };
      };
    };

    # ZRAM
    zramSwap = {
      enable = (utils.mkDefault) true;
      algorithm = (utils.mkDefault) "zstd"; # Compression algorithm
      memoryPercent = (utils.mkDefault) (
        100 # Total space shown(Not real compressed space!), in percent relative to RAM
      );
    };

    # Hibernation ("swapfile-hibernation.nix")
    system.hibernation = {
      enable = (utils.mkDefault) true;
      resumeDevice = config.fileSystems."/".device;
      swapfilePath = config.swap.devices."basicSwap".device;
      dataFile = {
        systemUser = args.hostArgs.userDev.username;
        absolutePath = "${args.hostArgs.configFolder}/hosts/${args.hostArgs.hostname}/hardware-data.json";
        storePath = (../. + "/${args.hostArgs.hostname}/hardware-data.json");
      };
    };

  };

}
