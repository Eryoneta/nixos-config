{ config-domain, ... }: {

  # LiCo
  imports = with config-domain.public; [
    "${programs}/store/nixos.nix.delayed.nix"
  ];

}
