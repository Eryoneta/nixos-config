# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Scan de hardware
      ./hardware-configuration.nix
    ];
  config = {
    system.nixos.label = "Test";
    #
    # Bootloader
    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 10; # 10 segundos
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true; # Localiza Windows 10
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
        extraEntriesBeforeNixOS = true;
        default = 3; # Menu seleciona NixOS como padrão
        configurationLimit = 100; # Quantidade máxima de gerações
        extraInstallCommands = ''
          TEMP_FILE="/boot/grub/grubTEMP.tmp"
          GRUB_FILE="/boot/grub/grub.cfg"
          ${pkgs.coreutils}/bin/echo "videoinfo" | ${pkgs.coreutils}/bin/cat - $GRUB_FILE > $TEMP_FILE && ${pkgs.coreutils}/bin/mv $TEMP_FILE $GRUB_FILE
        ''; # Atrasa Grub para que seu video carregue
      };
    };

    networking.hostName = "LiCo"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Sao_Paulo";

    # Select internationalisation properties.
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

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager = {
      sddm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "yo";
    };
    services.desktopManager.plasma6.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "br";
      variant = ""; # Lista de todos: man xkeyboard-config
    };

    # Configure console keymap
    console.keyMap = "br-abnt2";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.yo = {
      isNormalUser = true;
      description = "yo";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        kdePackages.kate
      #  thunderbird
      ];
    };

    # Install firefox.
    programs.firefox.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
      calibre
      vscodium
      gparted
      git
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    system.stateVersion = "24.05"; # Versão inicial do sistema. (Opções padrões).
    # (Mais em "man configuration.nix" ou em "https://nixos.org/nixos/options.html").
  };
}
