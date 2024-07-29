{ lib, ... }: (import ./nix.nix { inherit lib; }) // {
  config = {

    # Nix: Gerenciador de pacotes do sistema
    nix = {

      # Garbage Collector
      gc.dates = "Fri *-*-* 19:00:00"; # Toda sexta, 19h00

    };

  };
}
