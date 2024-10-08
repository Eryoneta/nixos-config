{ ... }@args: with args.config-utils; {
    config = {

      # Nix: System package manager
      nix = {

        # Garbage Collector
        gc = {
          automatic = mkDefault true;
          dates = mkDefault "*-*-* 18:00:00"; # Every day, 18h00
        };

        # Nix Store
        settings = {
          auto-optimise-store = mkDefault true; # Remove duplicates and creates hardlinks
          # TODO: Remove once flakes are sorted out(Might take a while!)
          experimental-features = [ "nix-command" "flakes" ]; # Experimental features
        };

        # Sync NIX_PATH with "inputs.nixpkgs.pkgs"
        # This means "nix-shell" uses "nixpkgs" from this flake and NOT "<nixpkgs>" from "nix-channel" (Obsolete!)
        #nixPath = [ "nixpkgs=${pkgs.path}" ];
        # Apparently, NixOS already does that: https://github.com/NixOS/nixpkgs/blob/release-24.05/nixos/modules/misc/nixpkgs-flake.nix

        # Sync Flake Registry with "inputs.nixpkgs"
        # This means "nix shell" uses "nixpkgs" from this flake and not necessarily "github:NixOS/nixpkgs/nixpkgs-unstable"
        #registry.nixpkgs.flake = inputs.nixpkgs;
        # Apparently, NixOS already does that: https://github.com/NixOS/nixpkgs/blob/release-24.05/nixos/modules/misc/nixpkgs-flake.nix

      };

    };
  }
