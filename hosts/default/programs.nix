{ config-domain, ... }: {

  # Default
  imports = with config-domain.public; [
    "${programs}/nixos.essential-programs.nix"
    "${programs}/store/nixos.nix.nix"
    #"${programs}/store/nixos.openssh.nix"
  ];

  # Pacotes
  config.nixpkgs.config.allowUnfree = true; # Precaução

}
