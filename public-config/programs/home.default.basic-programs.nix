{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Programs
    home = {
      packages = with pkgs-bundle; (
        (with unstable; [

        ])
        ++
        (with stable; [
          #kdePackages.kwrite # KWrite: (Light) Text editor (Included with KDE Plasma)
          kdePackages.kate # Kate: (Light) Code editor
        ])
        ++
        (with unstable-fixed; [

        ])
      );
    };
    
  };
}
