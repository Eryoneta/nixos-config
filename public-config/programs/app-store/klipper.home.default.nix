{ lib, config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.klipper = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.klipper; (lib.mkIf (options.enabled) {

    # Klipper: Clipboard manager
    # (Included with KDE Plasma)

    # Dotfile
    programs.plasma.configFile."klipperrc" = { # (plasma-manager option)
      "General" = {
        "IgnoreImages" = false; # Include images
        "KeepClipboardContents" = false; # Reset clipboard at every session
        "MaxClipItems" = 100; # Max items
      };
    };

  });

}
