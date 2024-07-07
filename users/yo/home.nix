{ config, pkgs, user, ... }:
    let
        mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
    in {
        # Home Manager
        home = {
            # Usuário
            username = user.username;
            homeDirectory = "/home/${user.username}";
            # Pacotes
            packages = with pkgs; [
                # Browsers
                firefox
                # Book Management
                calibre
                # Developer Tools
                kdePackages.kate # Editor de código
                vscodium         # Editor de código
                git              # Versionamento
            ];
            # Dotfiles
            file.".config/calibre".source = mkOutOfStoreSymlink "${user.dotFolder}/calibre/.config/calibre";
            # Versão Inicial
            stateVersion = "24.05"; # Versão inicial do Home Manager. (Opções padrões).
        };
        # AutoInstall
        programs.home-manager.enable = true;
    }
