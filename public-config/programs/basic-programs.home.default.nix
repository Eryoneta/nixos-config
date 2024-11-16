{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Programs
    home = {
      packages = with pkgs-bundle; (
        (with unstable; [
          xdg-ninja # xdg-ninja: Scans $HOME for uncompliant XDG files (Very convenient!)
        ])
        ++
        (with stable; [
          #kdePackages.kwrite # KWrite: (Light) Text editor (Included with KDE Plasma)
          #kdePackages.ark # Ark: File archiver (Included with KDE Plasma)
          #kdePackages.gwenview # Gwenview: Image viewer (Included with KDE Plasma)
          #kdePackages.okular # Okular: Document viewer (Included with KDE Plasma)
          kdePackages.kate # Kate: (Light) Code editor
          keepassxc # KeePassXC: Password manager
          yt-dlp # yt-dlp: YouTube downloader script
          jre8 # JRE8: Java Runtime Environment v8
        ])
        ++
        (with unstable-fixed; [

        ])
      );
    };
    
  };
}
