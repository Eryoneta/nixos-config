{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # VSCodium: Editor de código intermediário
      programs.vscode = { # VSCode, mas na realidade VSCodium
        enable = true;
        package = pkgs-bundle.stable.vscodium; # Pacote: Stable, AutoUpgrade
        extensions = with pkgs-bundle.stable.vscode-extensions; [
          jnoortheen.nix-ide # Nix IDE: Suporte para Nix
        ];
      };

    };
  }
