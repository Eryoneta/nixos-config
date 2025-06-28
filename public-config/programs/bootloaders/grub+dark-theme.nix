{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Grub: Bootloader
  config.modules."grub+dark-theme" = {
    tags = [ "personal-setup" ];
    attr.mkFilePath = config.modules."configuration".attr.mkFilePath;
    setup = { attr }: {
      nixos = { # (NixOS Module)

        # Theme
        config.boot.loader.grub.theme = (attr.mkFilePath {
          public-dotfile = "grub/blue-star-grub-theme/dark";
        });

      };
    };
  };

}
