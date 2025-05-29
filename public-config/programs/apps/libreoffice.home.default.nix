{ config, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.libreoffice = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.libreoffice; (lib.mkIf (options.enabled) {

    # LibreOffice: Free office suite
    home.packages = with options.packageChannel; [
      libreoffice # LibreOffice
      hunspell # Spell checker
      hunspellDicts.pt_BR # Spell dictionary
      hunspellDicts.en_US # Spell dictionary
    ];

  });

}
