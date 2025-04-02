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
          marktext # MarkText: Markdown text editor

          kdePackages.kconfig # KConfig: Tool for editing KDE config files
          inotify-tools # INotify-Tools: File event monitor
          kdialog # KDialog: Popup tool

          imagemagick # ImageMagick: Terminal based image editor
        ])
      );
    };

  };
}
