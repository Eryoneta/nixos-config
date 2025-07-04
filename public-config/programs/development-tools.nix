{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # MySQL: MySQL Database v8.0
  config.modules."mysql" = {
    enable = false; # Enable only when developing
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
