{ lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Nix: System package manager
      nix = {

        # Garbage Collector
        gc = {
          automatic = mkDefault true;
          dates = mkDefault "Fri *-*-* 18:00:00"; # Every friday, 18h00
        };

        # Nix Store
        settings = {
          auto-optimise-store = mkDefault true; # Remove duplicates and creates hardlinks
          # TODO: Remove once flakes are sorted out(Might take a while!)
          experimental-features = [ "nix-command" "flakes" ]; # Experimental features
        };

      };

    };
  }
