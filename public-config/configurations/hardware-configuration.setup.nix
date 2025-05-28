{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-hardware" = {

    # Configuration
    tags = [ "default-setup" ];

    setup = {
      nixos = { host, ... }: { # (NixOS Module)
        config = {

          # Kernel
          boot.initrd.availableKernelModules = (utils.mkDefault) [];
          boot.initrd.kernelModules = (utils.mkDefault) [];
          boot.kernelModules = (utils.mkDefault) [];
          boot.extraModulePackages = (utils.mkDefault) [];

          # Root partition
          fileSystems."/" = {
            device = (utils.mkDefault) "/dev/disk/by-label/NixOS";
            fsType = (utils.mkDefault) "ext4";
          };

          # Boot partition
          fileSystems."/boot" = {
            device = (utils.mkDefault) "/dev/disk/by-label/BOOT";
            fsType = (utils.mkDefault) "vfat";
            options = (utils.mkDefault) [ "fmask=0022" "dmask=0022" ];
          };

          # DHCP
          networking.useDHCP = (utils.mkDefault) true;

          # Nix Packages
          nixpkgs.hostPlatform = host.system.architecture;

        };
      };
    };
  };
}
