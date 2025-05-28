{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."basic-system-label" = {

    # Configuration
    tags = [ "basic-setup" ];

    setup.nixos = { host, inputs, ... }: { # (NixOS Module)
      config = {

        # Current-configuration label
        system.nixos.label = (
          let
            self = inputs.self;
            hasGitHash = (builtins.stringLength (self.shortRev or self.dirtyShortRev or "") > 0);
            hasPkgsHash = (builtins.stringLength (inputs.nixpkgs.rev or "") > 0);
          in if (hasGitHash && hasPkgsHash) then (
            inputs.nixpkgs.rev
          ) else (utils.formatStr host.system.label) #[a-zA-Z0-9:_.-]*
          # If the git repository is clean, then use "rev" from nixpkgs
          # Othewise use the label set in "host.system.label"
          # This is convenient to quickly get a valid commit hash to use as a input
          #   If a program is broken after a rebuild, it can use a known past working revision while the system stays updated
        );

        # Current configuration revision
        system.configurationRevision = (
          let
            self = inputs.self;
          in (builtins.toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown"))
          # Note:
          #   shortRev = Git current commit
          #   dirtyShortRev = Git current commit, but with modified files
          #   lastModified = Non-Git, only files in a directory (When built with "--flake path:CONFIG_PATH")
        );

      };

    };
  };
}
