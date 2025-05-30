{ ... }@args: with args.config-utils; { # (Setup Module)

  # Sound
  config.modules."sound" = {
    tags = [ "basic-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Sound
        config.services.pipewire = {
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

}
