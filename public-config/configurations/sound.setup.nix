{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."basic-sound" = {

    # Configuration
    tags = [ "basic-setup" ];

    setup = {
      nixos = { # (NixOS Module)
        config = {

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
      };
    };
  };
}
