{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # GParted: Manages partitions
  config.modules."gparted" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Install
        config.environment.systemPackages = with attr.packageChannel; [ gparted ];
      };
    };
  };

  # GSmartControl: Disk health inspection tool
  config.modules."gsmartcontrol" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Install
        config.environment.systemPackages = with attr.packageChannel; [ gsmartcontrol ];
      };
    };
  };

  # SmartMonTools: Disk health inspection tools
  config.modules."smartmontools" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Install
        config.environment.systemPackages = with attr.packageChannel; [ smartmontools ];
      };
    };
  };

  # KDiskMark: Disk speed tester
  config.modules."kdiskmark" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Install
        config.environment.systemPackages = with attr.packageChannel; [ kdiskmark ];
      };
    };
  };

  # Filelight: Disk usage visualizer
  config.modules."filelight" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Install
        config.environment.systemPackages = with attr.packageChannel; [ kdePackages.filelight ];
      };
    };
  };

  # PulseAudio Volume Control: Tool for system audio
  config.modules."pavucontrol" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Install
        config.environment.systemPackages = with attr.packageChannel; [ pavucontrol ];
      };
    };
  };

  # Mission Center: UI based process viewer
  config.modules."mission-center" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ mission-center ];
      };
    };
  };

}
