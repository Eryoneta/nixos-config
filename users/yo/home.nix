{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    # Home Manager
    home = {

      # Usuário
      username = user.username;
      homeDirectory = "/home/${user.username}";

      # Pacotes
      packages = []
      # Pacotes: Stable, AutoUpgrade
      ++ (with pkgs-bundle.stable; [
        kdePackages.kate        # Editor de código
        vscodium                # Editor de código
        git                     # Versionamento
        kdePackages.ktorrent    # Torrent
      ])
      # Pacotes: Unstable, AutoUpgrade
      ++ (with pkgs-bundle.unstable; [
        firefox                 # Navegador
      ])
      # Pacotes: Unstable, Manual Upgrade
      ++ (with pkgs-bundle.unstable-fixed; [
        calibre                 # Gerenciador de Livros
      ]);

      # Dotfiles
      file.".config/calibre".source = mkOutOfStoreSymlink "${user.dotFolder}/calibre/.config/calibre";

      # Versão Inicial
      stateVersion = "24.05"; # Versão inicial do Home Manager. (Opções padrões).
    };
    
    # AutoInstall
    # Funciona apenas para standalone. Como module, deve ser incluso em "configuration.nix"
    programs.home-manager.enable = true;
  }
