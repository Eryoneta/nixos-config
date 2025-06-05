{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # LibreOffice: Free office suite
  config.modules."libreoffice" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.home.packages = with attr.packageChannel; [
          libreoffice # LibreOffice
          hunspell # Spell checker
          hunspellDicts.pt_BR # Spell dictionary
          hunspellDicts.en_US # Spell dictionary
        ];

      };
    };
  };

}
