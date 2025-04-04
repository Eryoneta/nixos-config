{ lib, config, config-domain, ... }@args: with args.config-utils; {
  config = with config.profile.programs.grub; (lib.mkIf (options.enabled) {

    # Grub: Desktop Environment
    boot.loader.grub = {

      # Theme
      theme = "${config-domain.public.dotfiles}/grub/blue-star-grub-theme/dark";

    };

  });
}
