{ modules, host, ... }@args: with args.config-utils; {

  imports = with modules; [
    ./features/auto-upgrade.nix
    nixos-modules."link-to-source-config.nix"
  ];

  config = {
    
    # Auto-login
    services.displayManager = {
      autoLogin.enable = (utils.mkDefault) false;
      autoLogin.user = host.user.username;
    };

    # Link to source configuration ("link-to-source-config.nix")
    system.linkToSourceConfiguration = {
      enable = true;
      configurationPath = host.configFolderNixStore;
    };

    # FSTrim
    services.fstrim = {
      enable = (utils.mkDefault) true;
      interval = "weekly";
    };

  };

}
