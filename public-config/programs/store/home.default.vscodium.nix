{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # VSCodium: (Medium) Code editor
    programs.vscode = { # VSCode, mas na realidade VSCodium
      enable = mkDefault true;
      package = mkDefault pkgs-bundle.stable.vscodium;

      # Updates check
      enableUpdateCheck = mkDefault false; # Never check for updates
      enableExtensionUpdateCheck = mkDefault true; # Warn about extension updates

      # Extensions
      mutableExtensionsDir = mkDefault true;
      extensions = with pkgs-bundle.stable.vscode-extensions; [
        jnoortheen.nix-ide # Nix IDE: Nix sintax support
      ];

    };

  };
}
