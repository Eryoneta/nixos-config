{ ... }@args: with args.config-utils; { # (NixOS Module)
  config = {

    # Keyboard layout
    services.xserver.xkb = {
      layout = "br";
      variant = ""; # All available at: "man xkeyboard-config"
    };
    console.keyMap = "br-abnt2";

    # Sound
    services.pipewire = {
      enable = (utils.mkDefault) true;
      pulse = {
        enable = (utils.mkDefault) true;
      };
      alsa = {
        enable = (utils.mkDefault) true;
        support32Bit = (utils.mkDefault) true;
      };
    };

  };
}
