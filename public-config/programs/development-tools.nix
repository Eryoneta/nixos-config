{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # nix-output-monitor: Prettify nix output
  config.modules."nix-output-monitor" = {
    tags = [ "sysdev-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Install
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

  # KConfig: Tool for editing KDE config files
  config.modules."kconfig" = {
    tags = [ "sysdev-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kconfig ];
      };
    };
  };

  # INotify-Tools: Bundle of event tools
  config.modules."inotify-tools" = {
    tags = [ "sysdev-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ inotify-tools ];
      };
    };
  };

  # KDialog: Popup tool
  config.modules."kdialog" = {
    tags = [ "sysdev-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kdialog ];
      };
    };
  };

  # LibNotify: Notification tool
  config.modules."libnotify" = {
    tags = [ "sysdev-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ libnotify ];
      };
    };
  };

  # MySQL: MySQL Database v8.0
  config.modules."mysql" = {
    enable = true; # Enable only when developing
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Configuration
        config.services.mysql = {
          enable = true;
          package = (attr.packageChannel).mysql80;
        };
      };
    };
  };

  # MySQL Workbench: Tool for MySQL management
  config.modules."mysql-workbench" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ mysql-workbench ];
      };
    };
  };

  # Python: Full Python environment v3
  config.modules."python" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [
          (python3.withPackages (py-pkgs: (with py-pkgs; [
            pandas # Pandas: Library for data structures
            openpyxl # OpenPyXL: Library to read Microsoft Excel Spreadsheet files
            django # DJango: Framework for web-development with Python
            mysqlclient # MySQL Client: Allows for communication with a MySQL server
          ])))
        ];
      };
    };
  };

  # Java: Java Development Kit v17
  config.modules."java" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)
        # Configuration
        config.programs.java = {
          enable = true;
          package = with attr.packageChannel; (lib.hiPrio zulu17); # Zulu: Java Development Kit v17
          # Note: Has a collision with "eclipses.eclipse-java"
          #   Here, it should take priority
        };
      };
    };
  };

  # Eclipse(For Java): IDE for Java development
  config.modules."eclipse-java" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ eclipses.eclipse-java ];
      };
    };
  };

  # Angular-Cli: Helper for Angular development
  config.modules."angular-cli" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ nodePackages."@angular/cli" ];
      };
    };
  };

  # Hoppscotch: API tool
  config.modules."hoppscotch" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ hoppscotch ];
        # Desktop entry: Recreate with icon
        config.xdg.desktopEntries."hoppscotch" = {
          name = "Hoppscotch";
          exec = "hoppscotch";
          icon = "hoppscotch";
          comment = "Desktop App for hoppscotch.io";
          categories = [ "Development" ];
          type = "Application";
          terminal = false;
          mimeType = [ "x-scheme-handler/io.hoppscotch.desktop" ];
        };
      };
    };
  };

  # Dev Toolbox: Useful tools for developers
  config.modules."devtoolbox" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)
        # Install
        config.home.packages = with attr.packageChannel; [ devtoolbox ];
      };
    };
  };

}
