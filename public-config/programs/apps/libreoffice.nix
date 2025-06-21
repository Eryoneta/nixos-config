{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # LibreOffice: Free office suite
  config.modules."libreoffice" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.home.packages = with attr.packageChannel; [
          (utils.lowerPriority libreoffice) # LibreOffice
          # Note: Necessary to be able to change desktop entries
          hunspell # Spell checker
          hunspellDicts.pt_BR # Spell dictionary
          hunspellDicts.en_US # Spell dictionary
        ];

        # Desktop Entry: Recreate without the "Education" category
        config.xdg.desktopEntries."math" = {
          name = "LibreOffice Math";
          exec = "libreoffice --math %U";
          icon = "libreoffice-math";
          categories = [ "Office" ];
          type = "Application";
          terminal = false;
          mimeType = [
            "application/mathml+xml"
            "application/vnd.oasis.opendocument.formula"
            "application/vnd.oasis.opendocument.formula-template"
            "application/vnd.stardivision.math"
            "application/vnd.sun.xml.math"
            "application/x-starmath"
            "text/mathml"
          ];
          settings = {
            "GenericName" = "Formula Editor";
            "GenericName[pt_BR]" = "Editor de fórmulas";
            "Comment" = "Create and edit scientific formulas and equations.";
            "Comment[pt_BR]" = "Crie e edite fórmulas científicas e equações.";
            "StartupNotify" = "true";
          };
          # Note: As defined by the package
          #   (Can be seen at "~/.local/state/nix/profiles/home-manager-<GENERATION>-link/home-path/share/applications/")
        };
        # Note: Normally collides with the one provided with the package

      };
    };
  };

}
