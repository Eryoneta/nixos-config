{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Ark: File archiver
  config.modules."ark" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.ark ];
      };
    };
  };

  # Gwenview: Image viewer
  config.modules."gwenview" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.gwenview ];
        # Dotfile
        config.programs.plasma.configFile."gwenviewrc" = { # (plasma-manager option)
          "General" = {
            "HistoryEnabled" = false; # Do not show history
          };
          "ImageView" = {
            "MouseWheelBehavior" = "MouseWheelBehavior::Zoom"; # Mouse scroll = Zoom
          };
          "MainWindow" = {
            "MenuBar" = "Disabled"; # Do not show menu
          };
          "ThumbnailView" = {
            "LowResourceUsageMode" = true; # Speed above quality
            "Sorting" = "Sorting::Date"; # Sort by date
            "SortDescending" = true; # Newer first
          };
        };
      };
    };
  };

  # Okular: Document viewer
  config.modules."okular" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.okular ];
      };
    };
  };

  # Kamoso: Camera
  config.modules."kamoso" = {
    enable = false;
    # TODO: (Kamoso) Marked as broken. Check later
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kamoso ];
      };
    };
  };

  # KRename: Tool for mass file rename
  config.modules."krename" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ krename ];
      };
    };
  };

  # KolourPaint: Basic image editor
  config.modules."kolourpaint" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kolourpaint ];
      };
    };
  };

  # KeePassXC: Password manager
  config.modules."keepassxc" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ keepassxc ];
      };
    };
  };

  # Kalk: Calculator
  config.modules."kalk" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kalk ];
      };
    };
  };

  # OBS Studio: Video streamer
  config.modules."obs-studio" = {
    tags = [ "personal-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ obs-studio ];
      };
    };
  };

  # xdg-ninja: Scans $HOME for uncompliant XDG files
  config.modules."xdg-ninja" = {
    tags = [ "personal-setup" ];
    attr.packageChannel = pkgs-bundle.unstable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ xdg-ninja ];
      };
    };
  };

  # MarkText: Markdown text editor
  config.modules."marktext" = {
    enable = false; # Not used
    tags = [ "personal-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ marktext ];
      };
    };
  };

  # ImageMagick: Terminal based image editor
  config.modules."imagemagick" = {
    tags = [ "personal-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ imagemagick ];
      };
    };
  };

}
