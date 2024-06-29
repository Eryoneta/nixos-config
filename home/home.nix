{ config, pkgs, ... }: {

    home = {
        username = "yo";
        homeDirectory = "/home/yo";

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

        stateVersion = "24.05";
    };

    programs.home-manager.enable = true;
}
