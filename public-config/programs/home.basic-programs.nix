{ config, pkgs-bundle, user, ... }: {
  config = {

    # Pacotes do usuário
    home.packages = []
    # Pacotes: Stable, AutoUpgrade
    ++ (with pkgs-bundle.stable; [
      #kdePackages.kwrite # KWrite: Editor de texto simples (Incluso com KDE Plasma)
      kdePackages.kate # Kate: Editor de código simples
    ])
    # Pacotes: Unstable, AutoUpgrade
    ++ (with pkgs-bundle.unstable; [

    ])
    # Pacotes: Unstable, Manual Upgrade
    ++ (with pkgs-bundle.unstable-fixed; [

    ]);

  };
}
