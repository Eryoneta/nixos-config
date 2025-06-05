{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Kate: (Light) Code editor
  config.modules."kate" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kate ];

        # Dotfile
        config.programs.plasma.configFile."katerc" = { # (plasma-manager option)
          "KTextEditor Document" = {
            "Newline at End of File" = false; # Do NOT add a newline!
            "Remove Spaces" = 0; # Do NOT remove spaces from EndOfLines!
          };
        };

      };
    };
  };

}
