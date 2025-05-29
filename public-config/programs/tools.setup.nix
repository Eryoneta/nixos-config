{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Ark: File archiver
  config.modules."ark" = {
    enable = false; # (Included with KDE Plasma)
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.ark ];
      };
    };
  };

  # Gwenview: Image viewer
  config.modules."gwenview" = {
    enable = false; # (Included with KDE Plasma)
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" "tool-image" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.gwenview ];
      };
    };
  };

  # Okular: Document viewer
  config.modules."okular" = {
    enable = false; # (Included with KDE Plasma)
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" "tool-document" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.okular ];
      };
    };
  };

  # yt-dlp: YouTube downloader script
  config.modules."yt-dlp" = {
    attr.packageChannel = pkgs-bundle.unstable;
    tags = [ "tool" "tool-video" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ yt-dlp ];
      };
    };
  };

  # Kamoso: Camera
  config.modules."kamoso" = {
    enable = false;
    # TODO: (Kamoso) Marked as broken. Check later
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" "tool-video" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.kamoso ];
      };
    };
  };

  # OBS Studio: Video streamer
  config.modules."obs-studio" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-video" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.obs-studio ];
      };
    };
  };

  # KRename: Tool for mass file rename
  config.modules."krename" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.krename ];
      };
    };
  };

  # KolourPaint: Basic image editor
  config.modules."kolourpaint" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" "tool-image" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.kolourpaint ];
      };
    };
  };

  # KeePassXC: Password manager
  config.modules."keepassxc" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ keepassxc ];
      };
    };
  };

  # Kalk: Calculator
  config.modules."kalk" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-office" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.kalk ];
      };
    };
  };

  # xdg-ninja: Scans $HOME for uncompliant XDG files
  config.modules."xdg-ninja" = {
    attr.packageChannel = pkgs-bundle.unstable;
    tags = [ "tool" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ xdg-ninja ];
      };
    };
  };

  # MarkText: Markdown text editor
  config.modules."marktext" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-document" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ marktext ];
      };
    };
  };

  # KConfig: Tool for editing KDE config files
  config.modules."kconfig" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdePackages.kconfig ];
      };
    };
  };

  # INotify-Tools: Bundle of event tools
  config.modules."inotify-tools" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ inotify-tools ];
      };
    };
  };

  # KDialog: Popup tool
  config.modules."kdialog" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ kdialog ];
      };
    };
  };

  # ImageMagick: Terminal based image editor
  config.modules."imagemagick" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "tool" "tool-image" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ imagemagick ];
      };
    };
  };

}
