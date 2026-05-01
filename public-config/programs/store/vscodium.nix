{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # VSCodium: (Medium) Code editor
  config.modules."vscodium" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.mkFilePath = config.modules."configuration".attr.mkFilePath;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.vscode = { # VSCode, but actually VSCodium
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).vscodium;

          # Mutable extensions
          mutableExtensionsDir = (utils.mkDefault) true;

          # Default profile
          profiles.default = {

            # Updates check
            enableUpdateCheck = (utils.mkDefault) false; # Never check for updates
            enableExtensionUpdateCheck = (utils.mkDefault) true; # Warn about extension updates

            # Settings
            userSettings = (
              (
                # Simple settings
                utils.readJSONFile (attr.mkFilePath {
                  public-dotfile = "vscodium/.config/VSCodium/User/settings.json";
                  default-dotfile = "";
                })
              ) // {
                # Important settings
                "window.zoomLevel" = -1; # Unzooms a little
                "editor.selectionClipboard" = false; # Allows for multiline selections!
                "workbench.editor.pinnedTabsOnSeparateRow" = true; # Pinned tabs on a separated row!
                "workbench.layoutControl.enabled" = false; # Do not show layout buttons (Are not used)
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
            keybindings = (
              (
                # Unbindings
                utils.readJSONFile (attr.mkFilePath {
                  public-dotfile = "vscodium/.config/VSCodium/User/keybindings.json";
                  default-dotfile = "";
                })
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
            extensions = with (attr.packageChannel).vscode-extensions; [
              jnoortheen.nix-ide # Nix IDE: Nix sintax support
            ];

          };

        };

      };
    };
  };

  # VSCodium: (Medium) Code editor
  config.modules."vscodium.developer" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = config.modules."vscodium".attr.packageChannel;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Extras
        config.home.packages = with attr.packageChannel; [

          nixd # Nixd: Nix language server
          # Used by VSCodium to understand nix sintaxe

          nixfmt-rfc-style # NixFmt: Nix language formatter
          # Used by VSCodium to format nix code

        ];

        # Default profile
        config.programs.vscode.profiles.default = {

          # Settings
          userSettings = (
            {
              # Important settings
              "problems.decorations.enabled" = false; # Do not paint files and directories with warnings!
            } // ( 
              let
                /*
                flakeGetter = "(builtins.getFlake \"${user.configFolder}\")";
                nixosConfigName = "\"${user.host.name}\"";
                homeConfigName = "\"${user.name}@${user.host.name}\"";
                */ # Note: Evaluation is memory heavy and not really used here
              in {
                # Nix IDE extension configuration
                "nix.serverPath" = "nixd";
                "nix.enableLanguageServer" = true;
                "nix.serverSettings" = {
                  # NixD configuration
                  # Documentation: "https://github.com/nix-community/nixd'
                  # Note: There might be differences between the stable and unstable versions!
                  "nixd" = {

                    /*
                    "nixpkgs" = { # Use "pkgs" and "lib" from NixOS
                      # My packages from "pkgs-bundle" are not included. It seems "pkgs" is hardcoded...
                      # The same goes for my "config-utils"
                      "expr" = "import ${flakeGetter}.inputs.nixpkgs {}";
                    };
                    */ # Note: Evaluation is memory heavy and not really used here

                    "formatting" = { # Auto-format
                      "command" = [ "nixfmt" ];
                    };

                    /*
                    "options" = { # Use "options" from my configurations
                      # Note: The names are used to show where the suggestion came from
                      "nixos-options" = {
                        "expr" = "${flakeGetter}.nixosConfigurations.${nixosConfigName}.options";
                      };
                      "home_manager-options" = {
                        "expr" = "${flakeGetter}.homeConfigurations.${homeConfigName}.options";
                      };
                    };
                    */ # Note: Evaluation is memory heavy and not really used here

                    # Note: NixD can be used to eval packages/options and list them
                    #   The price is a few evaluations beforehand, which takes CPU and memory
                    #   Packages and options can be seen online, so... Eh

                    "diagnostics" = {
                      # Suppress warnings
                      # In VSCodium, a popup shows the diagnostic name(After the warning)
                      "suppress" = [
                        "sema-extra-with" # Unused "with"
                        # Note: "with" is used to import "utils" in all my modules, so sometimes it's unused
                        "sema-escaping-with" # Variable escapes "with"
                        # Note: A lot of variables do not use my "utils"
                        "parse-redundant-paren" # Redundant parenthesis
                        # Note: I use A LOT of parenthesis
                      ];
                      # TODO: (VsCodium/NixD) The warnings don't really go away. Bug? Check later
                    };
                  };
                };
                # Suppress some random popup errors
                # In VSCodium, the output terminal shows the ids
                "nix.hiddenLanguageServerErrors" = [
                  "textDocument/documentHighlight"
                  "textDocument/definition"
                ];
              }
            )
          );

          # Extensions
          extensions = (
            let
              vscode-marketplace-pkgs = (attr.packageChannel).vscode-utils.extensionFromVscodeMarketplace;
              vscode-marketplace-extensions = {

                # VSCode-Random: Includes many random generators
                jrebocho.vscode-random = (vscode-marketplace-pkgs {
                  publisher = "jrebocho";
                  name = "vscode-random";
                  version = "1.12.0";
                  sha256 = "sha256-J5m607m+HnMDApOphO8rOe8HhhU57afIx324o7puKkc=";
                });

              };
            in (
              (with (attr.packageChannel).vscode-extensions; [
                jnoortheen.nix-ide # Nix IDE: Nix sintax support
                mhutchie.git-graph # Git Graph: Shows a nice, interactive git log
              ])
              ++
              (with vscode-marketplace-extensions; [
                jrebocho.vscode-random # VSCode-Random
              ])
            )
          );

        };

      };
    };
  };

}
