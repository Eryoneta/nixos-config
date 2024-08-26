{ config-domain, ... }: {
    
  # Default
  imports = with config-domain.public; [
    "${programs}/basic-programs.nix"
    "${programs}/store/firefox.nix"
    "${programs}/store/vscodium.nix"
  ];

}
