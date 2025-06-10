{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # NPM: Package manager
  config.modules."npm" = {
    tags = [ "developer-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { # (NixOS Module)

        # Configuration
        config.programs.npm = {
          enable = true;
          package = (attr.packageChannel).nodePackages.npm;
        };

      };
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.zsh.initContent = ''
          # Include executables from "~/.npm/bin"
          export PATH="$HOME/.npm/bin:$PATH"
        '';

      };
    };
  };

}
