{ ... }@args: with args.config-utils; { # (Setup Module)

  # Grub: Bootloader
  config.modules."grub+dark-theme" = {
    tags = [ "personal-setup" ];
    setup = {
      nixos = { config-domain, ... }: { # (NixOS Module)

        # Theme
        config.boot.loader.grub.theme = (
          "${config-domain.public.dotfiles}/grub/blue-star-grub-theme/dark"
        );

      };
    };
  };

}
