{ config, host, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Server X11(Antigo)
      services.xserver.enable = mkDefault true;

      # Display Manager
      services.displayManager.sddm.enable = mkDefault true;

      # Desktop Environment
      services.desktopManager.plasma6.enable = mkDefault true;

    };
}
