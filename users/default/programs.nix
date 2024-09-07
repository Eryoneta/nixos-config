{ config-domain, ... }: {
    
  # Default
  imports = with config-domain.public; [
    "${programs}/home.basic-programs.nix"
    "${programs}/store/home.firefox.nix"
    "${programs}/store/home.vscodium.nix"
    "${programs}/store/home.ssh.nix"
  ];

}
