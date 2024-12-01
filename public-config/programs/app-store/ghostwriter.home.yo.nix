{ lib, config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.ghostwriter = {
      options.enabled = (utils.mkBoolOption false); # IT ALWAYS CRASHES
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.ghostwriter; (lib.mkIf (options.enabled) {

    # Ghostwriter: Writer tool
    programs.ghostwriter = { # (plasma-manager option)
      enable = options.enabled;
      package = (options.packageChannel).kdePackages.ghostwriter;
      general = {
        display = {
          hideMenubarInFullscreen = true; # Hide the topbar when in fullscreen
          interfaceStyle = "rounded"; # UI with curves
          showCurrentTimeInFullscreen = true; # Show clock
          showUnbreakableSpace = true; # Highlight non-space characters
        };
        fileSaving = {
          autoSave = true; # Autosave!
          backupFileOnSave = true; # Create a backup at every save
          backupLocation = "${config.xdg.dataHome}/ghostwriter/backups/"; # Same as default
        };
        session = {
          openLastFileOnStartup = true; # Auto-open last file
          rememberRecentFiles = true; # List recent files
        };
      };
      locale = "pt_BR"; # UI language
      window.sidebarOpen = false; # Start with the sidebar closed
    };

    # Dotfiles
    programs.plasma.configFile."kde.org/ghostwriter.conf" = { # (plasma-manager option)
      "Preview" = {
        # Note: This option is REQUIRED, or "Ghostwriter" crashes!
        "lastUsedExporter" = "cmark-gfm";
        # ...And that solution no longer works???
      };
    };

    home.packages = with options.packageChannel; [
      hunspellDicts.pt_BR # It crashes without it???
      hunspellDicts.en_US
    ];

  });

}
