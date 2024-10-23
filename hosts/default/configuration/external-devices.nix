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
      enable = utils.mkDefault true;
      alsa.enable = utils.mkDefault true;
      alsa.support32Bit = utils.mkDefault true;
      pulse.enable = utils.mkDefault true;
    };

  };
}
