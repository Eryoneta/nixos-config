{ auto-upgrade-pkgs, modules, host, ... }@args: with args.config-utils; {

  imports = with modules; [
    nixos-modules."auto-upgrade-git-support.nix"
    nixos-modules."auto-upgrade-update-flake-lock.nix"
    nixos-modules."auto-upgrade-alter-profile.nix"
  ];

  config = {
    # System AutoUpgrade
    system.autoUpgrade = {
      enable = mkDefault true;
      operation = "boot";
      allowReboot = false;
      persistent = true;
      dates = mkDefault "Fri *-*-* 16:00:00"; # Every friday, 16h00
      randomizedDelaySec = mkDefault "30min"; # Varies by 30min(Its best to not update right after booting)
      # Notice: The flake ignores submodules! The flag "submodules=1" is necessary
      # TODO: Remove once submodules are supported by default
      flake = "git+file://${host.configFolder}?submodules=1#${host.user.name}@${host.name}";

      gitSupport = {
        enable = mkDefault true;
        systemUser = host.user.username;
        directory = host.configFolder;
        markDirectoryAsSafe = mkDefault true;
        push = mkDefault true;
      };

      updateFlakeLock = {
        enable = mkDefault true;
        inputs = auto-upgrade-pkgs;
        commitLockFile = mkDefault true; # Commits "flake.lock"
      };

      alterProfile = {
        enable = mkDefault true;
        name = mkDefault "System_Updates";
        configurationLimit = mkDefault 24;
      };
      
    };
  };

}
