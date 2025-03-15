{ lib, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Programs
    home = {
      packages = with pkgs-bundle; (
        (with unstable; [
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

          krename # KRename: Tool for mass file rename

          kdePackages.kolourpaint # KolourPaint: Basic image editor

          keepassxc # KeePassXC: Password manager
        ])
      );
    };

  };
}
