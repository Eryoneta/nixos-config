{ config, pkgs, pkgs-stable, pkgs-unstable, user, ... }:
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
            # Pacotes: Stable, AutoUpdate
            ++ (with pkgs; [
                firefox                 # Navegador
                kdePackages.kate        # Editor de código
                vscodium                # Editor de código
                git                     # Versionamento
                kdePackages.ktorrent    # Torrent
            ])
            # Pacotes: Stable, Manual Update
            ++ (with pkgs-stable; [

            ])
            # Pacotes: Unstable, Manual Update
            ++ (with pkgs-unstable; [
                calibre                 # Gerenciador de Livros
            ]);
            # Dotfiles
            file.".config/calibre".source = mkOutOfStoreSymlink "${user.dotFolder}/calibre/.config/calibre";
            # Versão Inicial
            stateVersion = "24.05"; # Versão inicial do Home Manager. (Opções padrões).
        };
        # AutoInstall
        programs.home-manager.enable = true;
    }
