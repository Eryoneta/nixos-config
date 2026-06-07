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

  # Pinta: Basic image editor
  config.modules."pinta" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ pinta ];
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

  # Qalculate: Calculator
  config.modules."qalculate" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ qalculate-qt ];
        # Desktop Entry: Recreate without the "Education" category
        config.xdg.desktopEntries."io.github.Qalculate.qalculate-qt" = {
          name = "Qalculate! (Qt)";
          exec = "qalculate-qt";
          icon = "qalculate-qt";
          categories = [ "Utility" ];
          type = "Application";
          terminal = false;
          settings = {
            "GenericName" = "Calculator";
            "GenericName[pt_BR]" = "Calculadora";
            "Comment" = "Powerful and easy to use calculator";
            "Comment[pt_BR]" = "Calculadora potente e fácil de usar";
            "StartupNotify" = "true";
          };
          # Note: As defined by the package
          #   (Can be seen at "~/.local/state/nix/profiles/home-manager-<GENERATION>-link/home-path/share/applications/")
        };
      };
    };
  };

  # Zoom: Video conferencing app
  config.modules."zoom" = {
    tags = [ "work-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Configuration
        config.programs.zoom-us = {
          enable = true;
          package = (attr.packageChannel).zoom-us;
        };
      };
    };
  };

  # Zoom: Video conferencing app
  config.modules."zoom.personal" = {
    tags = [ "personal-setup" ];
    setup = {
      home = { # (Home-Manager Module)

        # Desktop entry: Remove "Zoom" from the StartMenu
        config.xdg.desktopEntries."Zoom" = {
          name = "Zoom";
          exec = "zoom";
          noDisplay = true; # Hide
        };

      };
    };
  };

}
