{ lib, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Programs
    home = {
      packages = with pkgs-bundle; (
        (with unstable; [

        ])
        ++
        (with stable; [
          eclipses.eclipse-java # Eclipse(For Java): IDE for Java development
          #jre8 # JRE8: Java Runtime Environment v8
          (lib.hiPrio zulu17) # Zulu: Java Development Kit v17
        ])
        ++
        (with unstable-fixed; [

        ])
      );
    };

  };
}
