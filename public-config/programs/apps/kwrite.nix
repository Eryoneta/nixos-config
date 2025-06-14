{ pkgs-bundle, userDev, ... }@args: with args.config-utils; { # (Setup Module)

  # KWrite: (Light) Text editor
  config.modules."kwrite" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    setup = { attr }: {
      home = { config, host, config-domain, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kate ];
        # Note: "kdePackages.kate" provides BOTH Kate and KWrite!

        # Dotfile
        config.programs.plasma.configFile."kwriterc" = { # (plasma-manager option)
          "General" = {
            "Show welcome view for new window" = false; # Do not show welcome view
          };
          "KTextEditor Document" = {
            "Newline at End of File" = false; # Do NOT add a newline!
            "Remove Spaces" = 0; # Do NOT remove spaces from EndOfLines!
            "Indent On Text Paste" = false; # Do NOT indent pasted text!
          };
          "KTextEditor Renderer" = {
            "Text Font" = "Comic Sans MS,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"; # Font (Comic Sans MS my beloved)
          };
          "KTextEditor View" = {
            "Auto Brackets" = false; # Do not autocomplete brackets (More trouble than helpful)
            "Show Line Ending Type in Statusbar" = true; # Show type of EOF in statusbar
            "Shoe Line Ending Type in Statusbar" = true; # Uh, someone made a typo (I'm gonna keep both so it works either way)
            # TODO: (KWrite) There is a typo in a config. Change it if it's fixed
            # Auto completion
            "Auto Completion" = false; # Do not autocomplete
            "Auto Completion Preselect First Entry" = false;
            "Enable Tab completion" = false;
            "Enter To Insert Completion" = false;
            "Word Completion" = false; # Do not autocomplete
            "Keyword Completion" = false; # Do not autocomplete
            "Show Documentation With Completion" = false;
            # Space-saving
            "Line Numbers" = false; # Do not show number alongside lines
            "Icon Bar" = false; # Do not show special icons (Bookmarked lines) alongside lines
            "Scroll Bar MiniMap" = false; # Do not show the minimap
            "Folding Bar" = false; # Do not show arrows to collapse blocks of code
          };
        };

        # Dotfile: Toolbar and shortcuts
        config.xdg.dataFile."kxmlgui5/kwrite/kateui.rc" = with config-domain; {
          source = (
            # Only the developer should be able to modify the file
            utils.mkIfElse (config.home.username == userDev.username && !host.system.virtualDrive) (
              utils.mkOutOfStoreSymlink "${outOfStore.public.dotfiles}/kwrite/.local/share/kxmlgui5/kwrite/kateui.rc"
            ) (
              "${public.dotfiles}/kwrite/.local/share/kxmlgui5/kwrite/kateui.rc"
            )
          );
        };
        # TODO: (KWrite) Watch out for the dotfile name! Currently, KWrite uses "kateui.rc"

      };
    };
  };

}
