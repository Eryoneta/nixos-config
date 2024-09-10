{ config, pkgs-bundle, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # VSCodium: (Medium) Code editor
      programs.vscode = { # VSCode, mas na realidade VSCodium
        enable = mkDefault true;
        package = mkDefault pkgs-bundle.stable.vscodium;

        # Extensions
        extensions = with pkgs-bundle.stable.vscode-extensions; [
          jnoortheen.nix-ide # Nix IDE: Nix sintax support
        ];

      };

    };
  }
