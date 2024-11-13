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
      randomizedDelaySec = (utils.mkDefault) "30min"; # Varies by 30min(Its best to not upgrade right after booting)
      # Notice: The flake ignores submodules! The flag "submodules=1" is necessary
      # TODO: (Config/AutoUpgrade) Remove once submodules are supported by default
      flake = "git+file://${host.configFolder}?submodules=1#${host.user.name}@${host.name}";

      gitSupport = {
        enable = (utils.mkDefault) true;
        systemUser = host.user.username;
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
        name = (utils.mkDefault) "System_Updates";
        configurationLimit = (utils.mkDefault) 24;
      };
      
    };
  };

}
