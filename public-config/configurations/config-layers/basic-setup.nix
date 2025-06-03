{ ... }@args: with args.config-utils; { # (Setup Module)

  # Basic setup
  config.modules."basic-setup" = {
    tags = [ "basic-setup" ];
    includeTags = [
      "core-setup"
      "essential-tool"
    ];
    setup = {
      nixos = { # (NixOS Module)

        # Experimental features
        config.nix.settings.experimental-features = [ "nix-command" "flakes" ];
        # TODO: (Nix) Remove once flakes are sorted out (Might take a while!)

      };
    };
  };

}
