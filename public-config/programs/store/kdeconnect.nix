{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # KDEConnect: Connects a smartphone and a desktop
  config.modules."kdeconnect" = {
    tags = [ "personal-setup" "work-setup" ];
    attr.packageChannel = pkgs-bundle.system;
    setup = { attr }: {
      nixos = { # (NixOS Module)

        # Configuration
        config.programs.kdeconnect = {
          enable = true;
          #package = (attr.packageChannel).kdePackages.kdeconnect-kde; # It causes a conflict
        };

      };
    };
  };

}
