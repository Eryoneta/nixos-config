{ lib, config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.konsole = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.konsole; (lib.mkIf (options.enabled) {

    # Konsole: Terminal
    # (Included with KDE Plasma)

    # Configuration
    programs.plasma.configFile."konsolerc" = { # (plasma-manager option)
      "Desktop Entry" = {
        "DefaultProfile" = "Yo.profile"; # Profile
      };
    };
    xdg.dataFile."konsole" = with config-domain; {
      source = with outOfStore.public; (
        utils.mkOutOfStoreSymlink "${dotfiles}/konsole/.local/share/konsole"
      );
    };

  });

}
