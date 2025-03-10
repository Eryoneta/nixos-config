{ lib, config, pkgs-bundle,  ... }@args: with args.config-utils; {

  options = {
    profile.programs.npm = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.npm; (lib.mkIf (options.enabled) {

    # NPM: Package manager
    # Include executables from "~/.npm/bin"
    programs.zsh.initExtra = utils.mkAfter ''
      export PATH="$HOME/.npm/bin:$PATH"
    '';

  });

}
