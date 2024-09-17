{ pkgs-bundle, ... }@args: with args.config-utils; {
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
