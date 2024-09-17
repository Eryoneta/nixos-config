{ ... }@args: with args.config-utils; {
  config = {

    # Server X11(Legacy)
    services.xserver.enable = mkDefault true;

    # Display Manager
    services.displayManager.sddm.enable = mkDefault true;

    # Desktop Environment
    services.desktopManager.plasma6.enable = mkDefault true;

  };
}
