{ lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Nix: Gerenciador de pacotes do sistema
      nix = {

        # Garbage Collector
        gc = {
          automatic = mkDefault true;
          dates = mkDefault "Fri *-*-* 18:00:00"; # Toda sexta, 18h00
        };

        # Nix Store
        settings = {
          auto-optimise-store = mkDefault true; # Remove duplicatas e cria hardlinks
          experimental-features = [ "nix-command" "flakes" ]; # Recursos Experimentais
        };

      };

    };
  }
