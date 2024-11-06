{ modules, host, ... }@args: with args.config-utils; {

  imports = with modules; [
    ./features/auto-upgrade.nix
    nixos-modules."link-to-source-config.nix"
    nixos-modules."swap-devices.nix"
  ];

  config = {
    
    # Auto-login
    services.displayManager = {
      autoLogin.enable = (utils.mkDefault) false;
      autoLogin.user = host.user.username;
    };

    # Link to source configuration ("link-to-source-config.nix")
    system.linkToSourceConfiguration = {
      enable = true;
      configurationPath = host.configFolderNixStore;
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
      memoryPercent = (utils.mkDefault) 50; # Total space shown, in percent relative to RAM
    };

  };

}
