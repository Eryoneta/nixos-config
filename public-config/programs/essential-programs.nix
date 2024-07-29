{ config, pkgs-bundle, user, ... }: {
  config = {

    # Pacotes do sistema
    environment.systemPackages = []
    # Pacotes: Stable, AutoUpgrade
    ++ (with pkgs-bundle.stable; [
      gparted       # GParted: Gerencia partições
      neofetch      # NeoFetch: Exibe informações do sistema (Deprecated)
      home-manager  # Home Manager: Gerencia home
      git           # Git: Versionamento
    ])
    # Pacotes: Unstable, AutoUpgrade
    ++ (with pkgs-bundle.unstable; [

    ])
    # Pacotes: Unstable, Manual Upgrade
    ++ (with pkgs-bundle.unstable-fixed; [

    ]);

  };
}
