{ config, host, lib, ... }:
  let
      mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Layout do Teclado
      services.xserver.xkb = {
        layout = "br";
        variant = ""; # Lista de todos: "man xkeyboard-config"
      };
      console.keyMap = "br-abnt2";

      # Impressoras
      services.printing.enable = true;

      # Som
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
