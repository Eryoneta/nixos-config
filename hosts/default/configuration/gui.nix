{ ... }@args: with args.config-utils; {
  config = {

    # Display Manager
    services.displayManager.sddm.wayland.enable = (utils.mkDefault) true;
    services.displayManager.sddm.enable = (utils.mkDefault) true;

    # Desktop Environment
    services.desktopManager.plasma6.enable = (utils.mkDefault) true;

  };
}
