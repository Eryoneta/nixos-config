{ pkgs-bundle, pkgs, ... }@args: with args.config-utils; {
  config = {

    # System programs
    environment.systemPackages = with pkgs-bundle; (
      (with unstable; [

      ])
      ++
      (with stable; [
        home-manager # Home-Manager: Manages home configuration
        fastfetch # FastFetch: Shows general system information
        gparted # GParted: Manages partitions
        git # Git: Versioning
        htop # HTop: Terminal-based process viewer
      ])
      ++
      (with unstable-fixed; [

      ])
    );

    # Do NOT include
    environment.plasma6.excludePackages = with pkgs; [
      kdePackages.elisa # Elisa: Music player (Not used)
    ];
    
  };
}
