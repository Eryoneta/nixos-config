{ ... }@args: with args.config-utils; { # (NixOS Module)

  imports = with args; [
    nixos-modules."auto-upgrade-git-support.nix"
    nixos-modules."auto-upgrade-update-flake-lock.nix"
    nixos-modules."auto-upgrade-alter-profile.nix"
    nixos-modules."auto-upgrade-notifier.nix"
  ];

  config = {

    # System AutoUpgrade
    system.autoUpgrade = {
      operation = "boot";
      allowReboot = false;
      persistent = true;
      dates = (utils.mkDefault) "Fri *-*-* 16:00:00"; # Every friday, 16h00
      randomizedDelaySec = (utils.mkDefault) "30min"; # Random delay of 30min (Its best to not upgrade right after booting)
      flake = "git+file://${args.host.configFolder}?submodules=1#${args.host.userDev.name}@${args.host.name}";
      # Notice: The flake ignores submodules! The flag "submodules=1" is necessary
      # TODO: (Config/AutoUpgrade) Remove once submodules are supported by default

      # Git support ("auto-upgrade-git-support.nix")
      gitSupport = {
        enable = (utils.mkDefault) true;
        systemUser = args.host.userDev.username;
        directory = args.host.configFolder;
        markDirectoryAsSafe = (utils.mkDefault) true;
        push = (utils.mkDefault) true;
      };

      # Update flake lock ("auto-upgrade-update-flake-lock.nix")
      updateFlakeLock = {
        enable = (utils.mkDefault) true;
        inputs = args.auto-upgrade-pkgs;
        commitLockFile = (utils.mkDefault) true; # Commits "flake.lock"
      };

      # Alter profile ("auto-upgrade-alter-profile.nix")
      alterProfile = {
        enable = (utils.mkDefault) true;
        name = (utils.mkDefault) "System_Upgrades";
        configurationLimit = (utils.mkDefault) 12; # 12 seems like a good mumber, 3 months of weekly upgrades
      };

      # Notifier ("auto-upgrade-notifier.nix")
      notifier = {
        enable = (utils.mkDefault) true;
        systemUser = args.host.userDev.username;
          informStart = {
            show = (utils.mkDefault) true;
            time = (utils.mkDefault) 15;
          };
          informConclusion = {
            show = (utils.mkDefault) true;
            time = (utils.mkDefault) "infinite";
          };
      };

    };

  };

}
