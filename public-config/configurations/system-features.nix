{ ... }@args: with args.config-utils; { # (Setup Module)

  # System features
  config.modules."system-features" = {
    tags = [ "default-setup" ];
    setup = {
      nixos = { config, host, nixos-modules, inputs, ... }: { # (NixOS Module)

        # Imports
        imports = [
          nixos-modules."link-to-source-config.nix"
          nixos-modules."swap-devices.nix"
          nixos-modules."swapfile-hibernation.nix"
        ];

        # Auto-login
        config.services.displayManager = {
          autoLogin.enable = (utils.mkDefault) false;
          autoLogin.user = host.userDev.username;
        };

        # Link to source configuration ("link-to-source-config.nix")
        config.system.linkToSourceConfiguration = {
          enable = true;
          configurationPath = host.configFolderNixStore;
        };

        # FSTrim
        config.services.fstrim = {
          enable = (utils.mkDefault) true;
          interval = "weekly";
        };

        # Swapfile ("swap-devices.nix")
        config.swap = {
          enable = (utils.mkDefault) true;
          devices = {
            "basicSwap" = {
              device = (utils.mkDefault) "/var/swapfile";
              size = (utils.mkDefault) (4 * 1024);
            };
          };
        };

        # ZRAM
        config.zramSwap = {
          enable = (utils.mkDefault) true;
          algorithm = (utils.mkDefault) "zstd"; # Compression algorithm
          memoryPercent = (utils.mkDefault) (
            100 # Total space shown(Not real compressed space!), in percent relative to RAM
          );
        };

        # Hibernation ("swapfile-hibernation.nix")
        config.system.hibernation = {
          enable = (utils.mkDefault) (!host.system.virtualDrive);
          resumeDevice = config.fileSystems."/".device;
          swapfilePath = config.swap.devices."basicSwap".device;
          dataFile = {
            systemUser = host.userDev.username;
            absolutePath = "${host.configFolder}/hosts/${host.hostname}/hardware-data.json";
            storePath = "${inputs.self.outPath}/hosts/${host.hostname}/hardware-data.json";
          };
        };

      };
    };
  };

}
