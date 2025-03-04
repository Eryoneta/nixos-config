{ auto-upgrade-pkgs, modules, host, ... }@args: with args.config-utils; {

  imports = with modules; [
    nixos-modules."auto-upgrade-git-support.nix"
    nixos-modules."auto-upgrade-update-flake-lock.nix"
    nixos-modules."auto-upgrade-alter-profile.nix"
  ];

  config = {
    # System AutoUpgrade
    system.autoUpgrade = {
      operation = "boot";
      allowReboot = false;
      persistent = true;
      dates = (utils.mkDefault) "Fri *-*-* 16:00:00"; # Every friday, 16h00
      randomizedDelaySec = (utils.mkDefault) "30min"; # Random delay of 30min (Its best to not upgrade right after booting)
      flake = "git+file://${host.configFolder}?submodules=1#${host.userDev.name}@${host.name}";
      # Notice: The flake ignores submodules! The flag "submodules=1" is necessary
      # TODO: (Config/AutoUpgrade) Remove once submodules are supported by default

      gitSupport = {
        enable = (utils.mkDefault) true;
        systemUser = host.userDev.username;
        directory = host.configFolder;
        markDirectoryAsSafe = (utils.mkDefault) true;
        push = (utils.mkDefault) true;
      };

      updateFlakeLock = {
        enable = (utils.mkDefault) true;
        inputs = auto-upgrade-pkgs;
        commitLockFile = (utils.mkDefault) true; # Commits "flake.lock"
      };

      alterProfile = {
        enable = (utils.mkDefault) true;
        name = (utils.mkDefault) "System_Upgrades";
        configurationLimit = (utils.mkDefault) 12; # 12 seems like a good mumber, 3 months of weekly upgrades
      };
      
    };
  };

}
