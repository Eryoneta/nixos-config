{ config-domain, ... }: {

  # LiCo
  imports = with config-domain.public; [
    "${programs}/store/nix.delayed.nix"
  ];

}
