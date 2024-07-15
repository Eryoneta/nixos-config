{ config, pkgs-bundle, host, lib, ... }:
  let
      mkDefault = value: lib.mkDefault value;
  in {
    imports = [
      ./boot-loader.nix
      ./external-devices.nix
      ./networking.nix
      ./gui.nix
      ./auto-upgrade.nix
    ];
    config = {

      # Label da Configuração Atual
      system.nixos.label = host.system.label; #[a-zA-Z0-9:_.-]*

      # Usuários
      users.users.${host.user.username} = {
        description = host.user.name;
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };

      # Autologin
      services.displayManager = {
        autoLogin.enable = mkDefault false;
        autoLogin.user = host.user.username;
      };

      # Pacotes
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs-bundle.stable; [
        gparted       # Gerencia partições
        neofetch      # Exibe informações do sistema (Deprecated)
        home-manager  # Gerencia home
        git           # Versionamento
      ];

      # Garbage Collector
      nix.gc = {
        automatic = mkDefault true;
        dates = mkDefault "Fri *-*-* 18:00:00"; # Toda sexta, 18h00
      };

      # Nix Store
      nix.settings.auto-optimise-store = mkDefault true; # Remove duplicatas e cria hardlinks

      # Recursos Experimentais
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Versão Inicial
      system.stateVersion = "24.05"; # Versão inicial do NixOS. (Opções padrões).
      # (Mais em "man configuration.nix" ou em "https://nixos.org/nixos/options.html").
    };
  }
