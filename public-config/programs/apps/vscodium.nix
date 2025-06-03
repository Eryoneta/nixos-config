{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # VSCodium: (Medium) Code editor
  config.modules."vscodium" = {
    attr.packageChannel = pkgs-bundle.unstable;
    tags = [ "default-setup" ];
    setup = { attr }: {
      home = { config-domain, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.vscode = { # VSCode, but actually VSCodium
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).vscodium;

          # Updates check
          enableUpdateCheck = (utils.mkDefault) false; # Never check for updates
          enableExtensionUpdateCheck = (utils.mkDefault) true; # Warn about extension updates

          # Settings
          userSettings = with config-domain; (
            (
              # Simple settings
              utils.readJSONFile "${public.dotfiles}/vscodium/.config/VSCodium/User/settings.json"
            ) // {
              # Important settings
              "window.zoomLevel" = -1; # Unzoom a little
              "editor.selectionClipboard" = false; # Allows for multiline selections!
              "workbench.editor.pinnedTabsOnSeparateRow" = true; # Pinned tabs on a separated row!
              "editor.renderWhitespace" = "all"; # Show spaces as dots
              "window.titleBarStyle" = "custom"; # Do not use the OS decorations (Smaller context menu)
              # Random settings
              "git.openRepositoryInParentFolders" = "never"; # Only open repos in the current folder
              "editor.tokenColorCustomizations" = {
                "textMateRules" = [
                  { # Undo the italic of comments, as it makes reading too hard
                    "scope" = "comment";
                    "settings" = {
                      "fontStyle" = "regular";
                    };
                  }
                ];
              };
              # Automatic settings
              "vsintellicode.modify.editor.suggestSelection" = "automaticallyOverrodeDefaultValue";
            } // (
              # Stylix tweak
              let
                sizes.terminal = 10; # Bigger font size
              in {
                # From https://github.com/danth/stylix/blob/release-24.11/modules/vscode/hm.nix
                "editor.fontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 + 0.5));
                "debug.console.fontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 + 0.5));
                "markdown.preview.fontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 + 0.5));
                "terminal.integrated.fontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 + 0.5));
                "chat.editor.fontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 + 0.5));
                "editor.minimap.sectionHeaderFontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 * 9 / 14 + 0.5));
                "scm.inputFontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 * 13 / 14 + 0.5));
                "screencastMode.fontSize" = (utils.mkForce) (builtins.floor (sizes.terminal * 4 / 3 * 56 / 14 + 0.5));
              }
            )
          );

          # Shortcuts
          keybindings = with config-domain; (
            (
              # Unbindings
              utils.readJSONFile "${public.dotfiles}/vscodium/.config/VSCodium/User/keybindings.json"
            ) ++ [
              # Bindings
              {
                "key" = "ctrl+d";
                "command" = "editor.action.deleteLines";
                "when" = "textInputFocus && !editorReadonly";
              }
              {
                "key" = "shift+alt+s";
                "command" = "saveAll";
              }
              {
                "key" = "alt+s";
                "command" = "editor.action.addSelectionToNextFindMatch";
              }
              {
                "key" = "ctrl+shift+c";
                "command" = "editor.action.commentLine";
                "when" = "editorTextFocus && !editorReadonly";
              }
              {
                "key" = "ctrl+p";
                "command" = "workbench.action.unpinEditor";
                "when" = "activeEditorIsPinned";
              }
              {
                "key" = "ctrl+p";
                "command" = "workbench.action.pinEditor";
                "when" = "!activeEditorIsPinned";
              }
              {
                "key" = "ctrl+shift+'";
                "command" = "workbench.action.terminal.toggleTerminal";
                "when" = "terminal.active";
              }
            ]
          );

          # Extensions
          mutableExtensionsDir = (utils.mkDefault) true;
          extensions = with (attr.packageChannel).vscode-extensions; [
            jnoortheen.nix-ide # Nix IDE: Nix sintax support
          ];

        };

      };
    };
  };

}
