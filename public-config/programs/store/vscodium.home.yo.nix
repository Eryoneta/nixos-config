{ config, config-domain, user, ... }@args: with args.config-utils; {
  config = with config.profile.programs.vscodium; {

    # Nixd: 
    home.packages = with options.packageChannel; [ nixd ];

    # VSCodium: (Medium) Code editor
    programs.vscode = {

      # Settings
      userSettings = with config-domain; (
        # Check for "./private-config/dotfiles"
        utils.mkIf (utils.pathExists private.dotfiles) (
          (
            utils.readJSONFile "${private.dotfiles}/vscodium/.config/VSCodium/User/settings.json"
          ) // {
            "editor.selectionClipboard" = false; # Allows for multiline selections!
          } // ( 
            let
              flakeGetter = "(builtins.getFlake \"${user.configFolder}\")";
              nixosConfigName = "\"${user.name}@${user.host.name}\"";
              homeConfigName = "\"${user.name}@${user.host.name}\"";
            in {
              # VSCodium configuration: Nix autocompletion
              "nix.serverPath" = "nixd";
              "nix.enableLanguageServer" = true;
              "nix.serverSettings" = {
                # NixD configuration
                "nixd" = {
                  "nixpkgs" = { # Use "options" from NixOS
                    "expr" = "import ${flakeGetter}.inputs.nixpkgs {}";
                  };
                  "formatting" = { # Auto-format
                    "command" = [ "nixfmt" ];
                  };
                  "options" = { # Use "options" from my configurations
                    # Note: The names are used to show where the suggestion came from
                    "nixos-options" = {
                      "expr" = "${flakeGetter}.nixosConfigurations.${nixosConfigName}.options";
                    };
                    "home_manager-options" = {
                      "expr" = "${flakeGetter}.homeConfigurations.${homeConfigName}.options";
                    };
                  };
                  "diagnostics" = {
                    # Suppress warnings
                    # In VSCodium, a popup shows the diagnostic name(After the warning)
                    "suppress" = [
                      # # Unused "with"
                      # ("with" is used to import "utils" in all my modules, so sometimes it's unused)
                      "sema-extra-with"
                      # Variable escapes "with"
                      # (A lot of variables do not use my "utils")
                      "sema-escaping-with" 
                    ];
                    # TODO: (VsCodium/NixD) The warnings from "sema-extra-with" do not go away. Bug? Check later
                  };
                };
              };
            }
          )
        )
      );

      # Shortcuts
      keybindings = with config-domain; (
        # Check for "./private-config/dotfiles"
        utils.mkIf (utils.pathExists private.dotfiles) (
          utils.readJSONFile "${private.dotfiles}/vscodium/.config/VSCodium/User/keybindings.json"
        )
      );

      # Extensions
      extensions = (
        let
          vscode-marketplace-pkgs = options.packageChannel.vscode-utils.extensionFromVscodeMarketplace;
          vscode-marketplace-extensions = {
            jrebocho.vscode-random = vscode-marketplace-pkgs {
              publisher = "jrebocho";
              name = "vscode-random";
              version = "1.12.0";
              sha256 = "sha256-J5m607m+HnMDApOphO8rOe8HhhU57afIx324o7puKkc=";
            };
          };
        in with options.packageChannel; (
          (with vscode-extensions; [
            jnoortheen.nix-ide # Nix IDE: Nix sintax support
            mhutchie.git-graph # Git Graph: Shows a nice, interactive git log
          ])
          ++
          (with vscode-marketplace-extensions; [
            jrebocho.vscode-random # VSCode-Random: Includes many random generators
          ])
        )
      );

    };

  };
}
