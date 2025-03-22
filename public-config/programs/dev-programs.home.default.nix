{ lib, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Programs
    home = {
      packages = with pkgs-bundle; (
        (with unstable; [

        ])
        ++
        (with stable; [
          (lib.hiPrio zulu17) # Zulu: Java Development Kit v17
          # Note: Has a collision with "eclipses.eclipse-java"

          (python3.withPackages (py-pkgs: (with py-pkgs; [ # Python: Full Python environment v3
            pandas # Pandas: Library for data structures
            openpyxl # OpenPyXL: Library to read Microsoft Excel Spreadsheet files

            django # DJango: Framework for web-development with Python
            mysqlclient # MySQL Client: Allows for communication with a MySQL server
          ])))

          eclipses.eclipse-java # Eclipse(For Java): IDE for Java development
          nodePackages."@angular/cli" # Angular-Cli: Helper for Angular development
          hoppscotch # Hoppscotch: API tool

          mysql-workbench # MySQL Workbench: Tool for MySQL management
        ])
      );
    };

  };
}
