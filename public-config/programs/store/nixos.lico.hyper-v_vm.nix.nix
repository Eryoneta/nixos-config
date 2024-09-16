{ tools, ... }: with tools; {
  config = {

    # Nix: System package manager
    nix = {

      # Garbage Collector
      gc.dates = "Fri *-*-* 19:00:00"; # Every friday, 19h00

    };

  };
}
