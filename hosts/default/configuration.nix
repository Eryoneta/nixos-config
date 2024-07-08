{ config, pkgs, host, lib, ... }:
  let
      mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Label da Configuração Atual
      system.nixos.label = host.system.label; #[a-zA-Z0-9:_.-]*

      # Bootloader
      boot.loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        timeout = mkDefault 10; # 10 segundos
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
          useOSProber = mkDefault true; # Localiza Windows 10
          extraEntries = ''
            menuentry "Firmware" {
              fwsetup
            }
            menuentry "Poweroff" {
              halt
            }
            menuentry "Reboot" {
              reboot
            }
          ''; # Menus extras
          extraEntriesBeforeNixOS = true; # Menus-extras não ficam no fim da lista! Então melhor encima
          default = 3; # Menu seleciona NixOS como padrão
          configurationLimit = mkDefault 100; # Quantidade máxima de gerações exibidas
        };
      };

      # Computador na Rede
      networking.hostName = host.name;

      # Internet
      networking.networkmanager.enable = true;

      # Proxy
      #networking.proxy.default = "http://user:password@proxy:port/";
      #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Firewall
      networking.firewall.enable = true;
      #networking.firewall.allowedTCPPorts = [ ... ];
      #networking.firewall.allowedUDPPorts = [ ... ];

      # Fuso Horário
      time.timeZone = "America/Sao_Paulo";

      # Localização
      i18n.defaultLocale = "pt_BR.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };

      # Server X11(Antigo)
      services.xserver.enable = true;

      # Display Manager
      services.displayManager = {
        sddm.enable = true;
      };

      # Desktop Environment
      services.desktopManager.plasma6.enable = true;

      # Layout do Teclado(X11)
      services.xserver.xkb = {
        layout = "br";
        variant = ""; # Lista de todos: man xkeyboard-config
      };

      # Layout do Teclado
      console.keyMap = "br-abnt2";

      # Impressoras
      services.printing.enable = true;

      # Som
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Usuários
      users.users.${host.user.username} = {
        description = host.user.name;
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };

      # Pacotes
      nixpkgs.config.allowUnfree = mkDefault true;
      environment.systemPackages = with pkgs; [
        gparted       # Gerencia partições
        neofetch      # Exibe informações do sistema (Deprecated)
        home-manager  # Gerencia HOME
      ];

      # OpenSSH
      services.openssh.enable = false;

      # Recursos Experimentais
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # System Update
      system.autoUpgrade = {
        enable = mkDefault true;
        operation = "boot";
        flags = [
          "--profile-name System_Updates"
          "--update-input nixpkgs"      # Update nixos
          "--update-input home-manager" # Update home-manager
          "--commit-lock-file" # Grava "flake.lock"
          "-L" # Imprime logs durante update
        ];
        allowReboot = false;
        persistent = true;
        dates = "Fri *-*-* 16:00:00"; # Toda sexta, 16h00
        randomizedDelaySec = "10min"; # Varia em 10min(Para não travar a rede em conjunto com outros PCs)
        flake = "git+file://${host.configFolder}#${host.user.name}@${host.name}";
      };

      # Garbage Collector
      systemd = (
        let
          name = "trim-system-update-profile";
          description = "Trim System_Updates profile";
          dates = "Fri *-*-* 17:00:00";
        in {
          timers.${name} = {
            description = description;
            wantedBy = [ "timers.target" ];
            partOf = [ "${name}.service" ];
            timerConfig.Persistent = true;
          };
          services.${name} = {
            serviceConfig.Type = "oneshot";
            restartIfChanged = false;
            path = with pkgs; [
              nix
            ];
            script = ''
              nix-env --delete-generations 60d --profile /nix/var/nix/profiles/system-profiles/System_Updates
            '';
            startAt = dates;
          };
        }
      );
      nix.gc = {
        automatic = true;
        dates = "Fri *-*-* 18:00:00"; # Toda sexta, 18h00
      };

      # Nix Store
      nix.settings.auto-optimise-store = true; # Remove duplicatas e cria hardlinks

      # Versão Inicial
      system.stateVersion = "24.05"; # Versão inicial do NixOS. (Opções padrões).
      # (Mais em "man configuration.nix" ou em "https://nixos.org/nixos/options.html").
    };
  }
