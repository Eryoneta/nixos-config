{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # MySQL: MySQL Database v8.0
  config.modules."mysql" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "development" "development-database" "server" ];
    setup = { attr }: {
      nixos = { # (NixOS Module)
        config.services.mysql = {
          enable = true;
          package = (attr.packageChannel).mysql80;
        };
      };
    };
  };

  # MySQL Workbench: Tool for MySQL management
  config.modules."mysql-workbench" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "development" "development-database" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ mysql-workbench ];
      };
    };
  };

  # Python: Full Python environment v3
  config.modules."python" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "development" "development-backend" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
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
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "development" "development-backend" "development-desktop" ];
    setup = { attr }: {
      nixos = { # (NixOS Module)
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
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "development" "development-desktop" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ eclipses.eclipse-java ];
      };
    };
  };

  # Angular-Cli: Helper for Angular development
  config.modules."angular-cli" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "development" "development-frontend" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ nodePackages."@angular/cli" ];
      };
    };
  };

  # Hoppscotch: API tool
  config.modules."hoppscotch" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "development" "development-backend" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.home.packages = with attr.packageChannel; [ hoppscotch ];
      };
    };
  };

}
