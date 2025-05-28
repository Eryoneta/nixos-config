{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-host" = {

    tags = [ "core" "basic" "default-user" ];

    setup.nixos = { # (NixOS Module)
      config = {

        # Start version
        system.stateVersion = "${args.host.system.stateVersion}"; # NixOS start version. (Default options)

      };
    };
  };
}
