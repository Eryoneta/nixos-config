{ config, host, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {

    imports = [
      ./configuration/boot-loader.nix
      ./configuration/external-devices.nix
      ./configuration/networking.nix
      ./configuration/gui.nix
      ./configuration/security.nix
    ] ++ [
      ./features.nix
      ./programs.nix
    ];

    # Default
    config = {

      # Label da Configuração Atual
      system.nixos.label = host.system.label; #[a-zA-Z0-9:_.-]*

      # Usuários
      users.users.${host.user.username} = {
        description = host.user.name;
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };

      # Versão Inicial
      system.stateVersion = "24.05"; # Versão inicial do NixOS. (Opções padrões).
      # (Mais em "man configuration.nix" ou em "https://nixos.org/nixos/options.html").
    };

  }
