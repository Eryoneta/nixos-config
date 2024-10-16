{ config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.vscodium = {
      options.enabled = (mkBoolOption true);
      options.packageChannel = (mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.vscodium; {

    # VSCodium: (Medium) Code editor
    programs.vscode = { # VSCode, but actually VSCodium
      enable = mkDefault options.enabled;
      package = mkDefault options.packageChannel.vscodium;

      # Updates check
      enableUpdateCheck = mkDefault false; # Never check for updates
      enableExtensionUpdateCheck = mkDefault true; # Warn about extension updates

      # Extensions
      mutableExtensionsDir = mkDefault true;
      extensions = with options.packageChannel.vscode-extensions; [
        jnoortheen.nix-ide # Nix IDE: Nix sintax support
      ];

    };

  };

}
