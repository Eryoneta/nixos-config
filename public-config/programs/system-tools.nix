{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # FastFetch: Shows general system information
  config.modules."fastfetch" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "essential-tool" "system-tool" ];
    setup = { attr }: {
      nixos = { # (NixOS Module)
        config.environment.systemPackages = with attr.packageChannel; [ fastfetch ];
      };
    };
  };

  # GParted: Manages partitions
  config.modules."gparted" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "essential-tool" "system-tool" ];
    setup = { attr }: {
      nixos = { # (NixOS Module)
        config.environment.systemPackages = with attr.packageChannel; [ gparted ];
      };
    };
  };

  # nix-output-monitor: Prettify nix output
  config.modules."nix-output-monitor" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "essential-tool" "system-tool" ];
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

  # Filelight: Disk usage visualizer
  config.modules."filelight" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "system-tool" ];
    setup = { attr }: {
      nixos = { # (NixOS Module)
        config.environment.systemPackages = with attr.packageChannel; [ kdePackages.filelight ];
      };
    };
  };

  # PulseAudio Volume Control: Tool for system audio
  config.modules."pavucontrol" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "system-tool" ];
    setup = { attr }: {
      nixos = { # (NixOS Module)
        config.environment.systemPackages = with attr.packageChannel; [ pavucontrol ];
      };
    };
  };

}
