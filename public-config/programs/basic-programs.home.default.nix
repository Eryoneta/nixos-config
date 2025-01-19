{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Programs
    home = {
      packages = with pkgs-bundle; (
        (with unstable; [
          xdg-ninja # xdg-ninja: Scans $HOME for uncompliant XDG files (Very convenient!)
          yt-dlp # yt-dlp: YouTube downloader script
        ])
        ++
        (with stable; [
          #kdePackages.ark # Ark: File archiver (Included with KDE Plasma)
          #kdePackages.gwenview # Gwenview: Image viewer (Included with KDE Plasma)
          #kdePackages.okular # Okular: Document viewer (Included with KDE Plasma)
          kdePackages.kcalc # KCalc: Calculator
          #kdePackages.kamoso # Kamoso: Camera
          # TODO: (Kamoso) Marked as broken. Check later
          obs-studio # OBS Studio: Video streamer
          kdePackages.kconfig # KConfig: Tool for editing KDE config files
          krename # KRename: Tool for mass file rename
          kdePackages.kolourpaint # KolourPaint: Basic image editor
          imagemagick # ImageMagick: Terminal based image editor
          inotify-tools # INotify-Tools: File event monitor

          keepassxc # KeePassXC: Password manager
          jre8 # JRE8: Java Runtime Environment v8
          eclipses.eclipse-java # Eclipse(For Java): IDE for Java development
          marktext # MarkText: Markdown text editor

        ])
        ++
        (with unstable-fixed; [

        ])
      );
    };

  };
}
