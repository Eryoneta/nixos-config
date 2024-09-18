{ ... }@args: with args.config-utils; {
  config = {

    # Keyboard layout
    services.xserver.xkb = {
      layout = "br";
      variant = ""; # All available at: "man xkeyboard-config"
    };
    console.keyMap = "br-abnt2";

    # Printers
    services.printing.enable = true;

    # Sound
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };
}
