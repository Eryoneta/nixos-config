{ ... }@args: with args.config-utils; { # (Setup Module)

  # Experimental features
  config.modules."experimental-features" = {
    tags = [ "basic-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Experimental features
        config.nix.settings.experimental-features = [ "nix-command" "flakes" ];
        # TODO: (Nix) Remove once flakes are sorted out (Might take a while!)

      };
    };
  };
}
