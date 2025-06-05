{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Ghostwriter: Writer tool
  config.modules."ghostwriter" = {
    tags = [ "personal-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.ghostwriter = { # (plasma-manager option)
          enable = true;
          package = (attr.packageChannel).kdePackages.ghostwriter;
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
        config.programs.plasma.configFile."kde.org/ghostwriter.conf" = { # (plasma-manager option)
          "Preview" = {
            # Note: This option is REQUIRED, or "Ghostwriter" crashes!
            "lastUsedExporter" = "cmark-gfm";
            # ...And that solution no longer works???
          };
        };

        config.home.packages = with attr.packageChannel; [
          hunspellDicts.pt_BR # It crashes without it???
          hunspellDicts.en_US
        ];

      };
    };
  };

}
