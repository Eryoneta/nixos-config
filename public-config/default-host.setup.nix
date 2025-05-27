{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-host" = {

    tags = [ "default-user" ];

    setup.nixos = { # (NixOS Module)
      imports = [
        ./hardware-configuration.nixos.nix
        ./bootloader.nixos.nix
        ./external-devices.nixos.nix
        ./fonts.nixos.nix
        ./security.nixos.nix
        ./features.nixos.nix
        ./users.nixos.nix
      ];
    };
  };
}
