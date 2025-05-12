{ ... }@args: with args.config-utils; {

    imports = [
      ./configuration/boot-loader.nix
      ./configuration/external-devices.nix
      ./configuration/networking.nix
      ./configuration/security.nix
      ./configuration/fonts.nix
    ] ++ [
      ./hardware-configuration.nix
      ./features.nix
      ./programs.nix
      ./users.nix
    ];

    config = {

      # Current-configuration label
      system.nixos.label = (
        let
          self = args.inputs.self;
          hasGitHash = (builtins.stringLength (self.shortRev or self.dirtyShortRev or "") > 0);
          hasPkgsHash = (builtins.stringLength (args.inputs.nixpkgs.rev or "") > 0);
        in if (hasGitHash && hasPkgsHash) then (
          args.inputs.nixpkgs.rev
        ) else (utils.formatStr args.host.system.label) #[a-zA-Z0-9:_.-]*
      );

      # Current configuration revision
      system.configurationRevision = (
        let
          self = args.inputs.self;
        in (builtins.toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown"))
        # Note:
        #   shortRev = Git current commit
        #   dirtyShortRev = Git current commit, but with modified files
        #   lastModified = Non-Git, only files in a directory (When built with "--flake path:...")
      );

      # Start version
      system.stateVersion = "24.05"; # NixOS start version. (Default options).
      # (More with "man configuration.nix" or "https://nixos.org/nixos/options.html").
      
    };

  }
