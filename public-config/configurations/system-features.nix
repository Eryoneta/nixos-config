{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

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
            absolutePath = "${host.configFolder}/hosts/${host.hostname}.hardware-data.json";
            storePath = "${inputs.self.outPath}/hosts/${host.hostname}.hardware-data.json";
          };
        };

      };
    };
  };

  # Auto-upgrade
  config.modules."system-features+auto-upgrade" = {
    tags = [ "default-setup" ];
    attr.configurationLimit = 12; # 12 seems like a good mumber, 3 months of weekly upgrades
    attr.systemUpgradeProfileName = "System_Upgrades";
    setup = { attr }: {
      nixos = { host, nixos-modules, auto-upgrade-pkgs, ... }: { # (NixOS Module)

        # Imports
        imports = [
          nixos-modules."auto-upgrade-git-support.nix"
          nixos-modules."auto-upgrade-update-flake-lock.nix"
          nixos-modules."auto-upgrade-alter-profile.nix"
          nixos-modules."auto-upgrade-notifier.nix"
        ];

        # System AutoUpgrade
        config.system.autoUpgrade = {
          enable = (utils.mkDefault) true;
          operation = "boot";
          allowReboot = false;
          persistent = true;
          dates = (utils.mkDefault) "Fri *-*-* 16:00:00"; # Every friday, 16h00
          randomizedDelaySec = (utils.mkDefault) "30min"; # Random delay of 30min (Its best to not upgrade right after booting)
          flake = "git+file://${host.configFolder}?submodules=1#${host.name}";
          # Notice: The flake ignores submodules! The flag "submodules=1" is necessary
          # TODO: (Config/AutoUpgrade) Remove once submodules are supported by default

          # Git support ("auto-upgrade-git-support.nix")
          gitSupport = {
            enable = (utils.mkDefault) true;
            systemUser = host.userDev.username;
            directory = host.configFolder;
            markDirectoryAsSafe = (utils.mkDefault) true;
            push = (utils.mkDefault) true;
          };

          # Update flake lock ("auto-upgrade-update-flake-lock.nix")
          updateFlakeLock = {
            enable = (utils.mkDefault) true;
            inputs = auto-upgrade-pkgs;
            commitLockFile = (utils.mkDefault) true; # Commits "flake.lock"
          };

          # Alter profile ("auto-upgrade-alter-profile.nix")
          alterProfile = {
            enable = (utils.mkDefault) true;
            name = (utils.mkDefault) attr.systemUpgradeProfileName;
            configurationLimit = (utils.mkDefault) attr.configurationLimit;
          };

          # Notifier ("auto-upgrade-notifier.nix")
          notifier = {
            enable = (utils.mkDefault) true;
            systemUser = host.userDev.username;
            informStart = {
              show = (utils.mkDefault) true;
              time = (utils.mkDefault) 15;
              promptConfirmation = (utils.mkDefault) true;
            };
            informConclusion = {
              show = (utils.mkDefault) true;
              time = (utils.mkDefault) "infinite";
            };
          };

        };

      };
    };
  };

}
