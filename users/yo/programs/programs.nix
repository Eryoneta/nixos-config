{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    imports = [
      ./git.nix       # Versionador
      ./firefox.nix   # Navegador
      ./calibre.nix   # Biblioteca de Livros
      ./vscodium.nix  # Editor de código (Intermediário)
    ];

    # Pacotes
    home.packages = []
    # Pacotes: Stable, AutoUpgrade
    ++ (with pkgs-bundle.stable; [
      kdePackages.kate        # Editor de código (Simples)
      kdePackages.ktorrent    # Torrent
    ])
    # Pacotes: Unstable, AutoUpgrade
    ++ (with pkgs-bundle.unstable; [

    ])
    # Pacotes: Unstable, Manual Upgrade
    ++ (with pkgs-bundle.unstable-fixed; [

    ]);

  }
