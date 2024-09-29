{ ... }@args: with args.config-utils; {
  config = {

    # Keyboard layout
    services.xserver.xkb = {
      layout = "br";
      variant = ""; # All available at: "man xkeyboard-config"
    };
    console.keyMap = "br-abnt2";

    # Sound
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = mkDefault true;
      alsa.enable = mkDefault true;
      alsa.support32Bit = mkDefault true;
      pulse.enable = mkDefault true;
    };

  };
}
