{ pkgs-bundle, ... }: {
  config = {

    # System programs
    environment.systemPackages = with pkgs-bundle; (
      (with unstable; [

      ])
      ++
      (with stable; [
        gparted # GParted: Manages partitions
        fastfetch # FastFetch: Shows general system information
        home-manager # Home-Manager: Manages home configuration
        git # Git: Versioning
      ])
      ++
      (with unstable-fixed; [

      ])
    );
    
  };
}
