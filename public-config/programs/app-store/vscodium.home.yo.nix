{ lib, config, config-domain, user, ... }@args: with args.config-utils; {
  config = with config.profile.programs.vscodium; (lib.mkIf (options.enabled) {

    home.packages = with options.packageChannel; [

      # Nixd: Nix language server
      # Used by VSCodium to understand nix sintaxe
      nixd
      
      # NixFmt: Nix language formatter
      # Used by VSCodium to format nix code
      nixfmt-rfc-style

    ];

    # VSCodium: (Medium) Code editor
    programs.vscode = {

      # Settings
      userSettings = with config-domain; (
        {
          # Important settings
          "problems.decorations.enabled" = false; # Do not paint files and directories with warnings!
        } // ( 
          let
            flakeGetter = "(builtins.getFlake \"${user.configFolder}\")";
            nixosConfigName = "\"${user.name}@${user.host.name}\"";
            homeConfigName = "\"${user.name}@${user.host.name}\"";
          in {
            # Nix IDE extension configuration
            "nix.serverPath" = "nixd";
            "nix.enableLanguageServer" = true;
            "nix.serverSettings" = {
              # NixD configuration
              # Documentation: "https://github.com/nix-community/nixd'
              # Note: There might be differences between the stable and unstable versions!
              "nixd" = {
                "nixpkgs" = { # Use "pkgs" and "lib" from NixOS
                  # My packages from "pkgs-bundle" are not included. It seems "pkgs" is hardcoded...
                  # The same goes for my "config-utils"
                  "expr" = "import ${flakeGetter}.inputs.nixpkgs {}";
                  # TODO: (VSCodium/NixD) Include the content of "pkgs-bundle" into "pkgs.channels"?
                  # TODO: (VSCodium/NixD) Include the content of "config-utils" into "lib.config-utils"?
                  # TODO: (VSCodium/NixD) instead of "inputs", read a "output.nixpkgs-modified"?
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
          vscode-marketplace-pkgs = options.packageChannel.vscode-utils.extensionFromVscodeMarketplace;
          vscode-marketplace-extensions = {
            
            # VSCode-Random: Includes many random generators
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
            jrebocho.vscode-random # VSCode-Random
          ])
        )
      );

    };

  });
}
