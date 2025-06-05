{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # SDDM: Display Manager
  config.modules."sddm" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system;
    setup = { attr }: {
      nixos = { # (NixOS Module)

        # Configuration
        config.services.displayManager.sddm = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).kdePackages.sddm;

          # Wayland
          wayland.enable = (utils.mkDefault) true; # Wayland support

        };

      };
    };
  };

}
