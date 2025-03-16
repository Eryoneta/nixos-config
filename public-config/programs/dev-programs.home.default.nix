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
          python3Full # Python: Full Python environment v3

          eclipses.eclipse-java # Eclipse(For Java): IDE for Java development
          nodePackages."@angular/cli" # Angular-Cli: Helper for Angular development
          hoppscotch # Hoppscotch: API tool
          mysql-workbench # MySQL Workbench: Tool for MySQL management
        ])
      );
    };

  };
}
