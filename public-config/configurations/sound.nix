{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Sound
  config.modules."sound" = {
    tags = [ "basic-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # PipeWire: Framework for sound
        config.services.pipewire = {
          enable = (utils.mkDefault) true;

          # PulseAudio support
          pulse = { # PulseAudio: Sound server
            enable = (utils.mkDefault) true;
          };

          # ALSA support
          alsa = { # ALSA: Sound drivers
            enable = (utils.mkDefault) true;
            support32Bit = (utils.mkDefault) true;
          };

        };

      };
    };
  };

}
