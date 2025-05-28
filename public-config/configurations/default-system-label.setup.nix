{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-host" = {

    tags = [ "basic" "default-user" ];

    setup.nixos = { # (NixOS Module)
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

      };

    };
  };
}
