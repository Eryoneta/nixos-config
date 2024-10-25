{ config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.vscodium = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.unstable);
    };
  };

  config = with config.profile.programs.vscodium; {

    # VSCodium: (Medium) Code editor
    programs.vscode = { # VSCode, but actually VSCodium
      enable = (utils.mkDefault) options.enabled;
      package = (utils.mkDefault) options.packageChannel.vscodium;

      # Updates check
      enableUpdateCheck = (utils.mkDefault) false; # Never check for updates
      enableExtensionUpdateCheck = (utils.mkDefault) true; # Warn about extension updates

      # Extensions
      mutableExtensionsDir = (utils.mkDefault) true;
      extensions = with options.packageChannel.vscode-extensions; [
        jnoortheen.nix-ide # Nix IDE: Nix sintax support
      ];

    };

  };

}
