{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # GParted: Manages partitions
  config.modules."gparted" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
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
        config.environment.systemPackages = with attr.packageChannel; [ kdePackages.filelight ];
      };
    };
  };

  # nix-output-monitor: Prettify nix output
  config.modules."nix-output-monitor" = {
    tags = [ "sysdev-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        config.environment.systemPackages = with attr.packageChannel; [ nix-output-monitor ];
      };
    };
    # Note: Best usage is "sudo ls /dev/null > /dev/null 2>&1 && sudo nixos-rebuild switch --flake <PATH>#<HOSTNAME> --use-remote-sudo --show-trace --print-build-logs --verbose |& nom"
    #   "sudo ls /dev/null > /dev/null 2>&1" requires sudo password, and passes that to "nixos-rebuild"
    #     Otherwise, the password prompt is invisible
    #   "--use-remote-sudo" means only use sudo at the end
    #   "--show-trace" is for full error messages
    #   "--print-build-logs --verbose" is for very detailed output
    #   "|& nom" passes the output to nix-output-monitor to prettify
  };

  # PulseAudio Volume Control: Tool for system audio
  config.modules."pavucontrol" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
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
        config.home.packages = with attr.packageChannel; [ mission-center ];
      };
    };
  };

}
