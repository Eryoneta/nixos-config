{ config-domain, ... }: {

  # Default
  imports = with config-domain.public; [
    "${programs}/essential-programs.nix"
    "${programs}/store/nix.nix"
    #"${programs}/store/openssh.nix"
  ];

  # Pacotes
  config.nixpkgs.config.allowUnfree = true; # Precaução

}
