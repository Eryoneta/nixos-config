{ config, user, ... }: {

  imports = [
    ./programs.nix
  ];

  # Default
  config = {
    # Home Manager
    home = {

      # Usuário
      username = user.username;
      homeDirectory = "/home/${user.username}";

      # Versão Inicial
      stateVersion = "24.05"; # Versão inicial do Home Manager. (Opções padrões).

    };

    # AutoInstall
    # Funciona apenas para standalone. Como module, deve ser incluso em "configuration.nix"
    programs.home-manager.enable = true;

  };
}
