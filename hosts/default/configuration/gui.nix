{ ... }@args: with args.config-utils; {
  config = {

    # Display Manager
    services.displayManager.sddm.wayland.enable = mkDefault true;
    services.displayManager.sddm.enable = mkDefault true;

    # Desktop Environment
    services.desktopManager.plasma6.enable = mkDefault true;

  };
}
