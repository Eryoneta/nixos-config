{ ... }@args: with args.config-utils; { # (Setup Module)

  # System label
  config.modules."system-label" = rec {
    tags = [ "basic-setup" ];
    attr.gitRevision = self: (
      let
        isValid = self: rev: (
          ((self.${rev} or "") != "" && (builtins.stringLength (self.${rev} or "")) > 1)
        );
      in (
        if (isValid self "shortRev") then self.shortRev else (
          if (isValid self "dirtyShortRev") then self.dirtyShortRev else ""
        )
      )
      
    );
    attr.nixosLabel = self: nixpkgsRevision: freeLabel: (
      let
        hasGitRev = ((attr.gitRevision self) != "");
        hasNixpkgsRev = (nixpkgsRevision != "");
      in (
        if (hasGitRev && hasNixpkgsRev) then (
          nixpkgsRevision
        ) else (utils.formatStr freeLabel) # [a-zA-Z0-9:_.-]*
        # If the flake is called with "git+file://<FLAKE_PATH>", then there will be a git revision
        #   Here, it returns a nixpkgs revision
        #     This is a very convenient way to quickly get a valid commit hash to use as an input!
        #     Broken program after an update? Just add another flake input: "github:NixOS/nixpkgs/<nixpkgsRevision>"
        #     The system can keep using the updated input, and the broken program can use the newly added fixed input
        # If the flake is called with "path:<FLAKE_PATH>", then there will NOT be a git revision
        #   Here, it returns a custom label. Great for naming generations
      )
    );
    attr.configurationRevision = self: (
      let
        gitRev = (attr.gitRevision self);
        lastModified = (
          if ((self.lastModified or 0) > 0) then (
            (builtins.toString self.lastModified)
          ) else ""
        );
      in (
        if (gitRev != "") then gitRev else (
          if (lastModified != "") then lastModified else (
            "unknown"
          )
        )
        # Returns either git revision or last modified date
      )
    );
    setup = { attr }: {
      nixos = { inputs, host, ... }: { # (NixOS Module)

        # Current-configuration label
        config.system.nixos.label = (attr.nixosLabel inputs.self (inputs.nixpkgs.rev or "") host.system.label);

        # Current configuration revision
        config.system.configurationRevision = (attr.configurationRevision inputs.self);

      };
    };
  };

}
