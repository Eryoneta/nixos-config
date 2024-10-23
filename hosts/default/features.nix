{ modules, host, ... }@args: with args.config-utils; {

  imports = with modules; [
    ./features/auto-upgrade.nix
    nixos-modules."link-to-source-config.nix"
  ];

  config = {
    
    # Auto-login
    services.displayManager = {
      autoLogin.enable = utils.mkDefault false;
      autoLogin.user = host.user.username;
    };

    # Link to source configuration
    system.linkToSourceConfiguration = {
      enable = true;
      configurationPath = host.configFolderNixStore;
    };

  };

}
