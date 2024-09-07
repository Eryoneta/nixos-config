{ config-domain, ... }: {
    
  # Yo
  imports = (
    (with config-domain.public; [
      "${programs}/store/home.git.nix"
      "${programs}/store/home.calibre.nix"
    ])
    ++
    (with config-domain.private; [
      "${programs}/home.other-programs.nix"
      "${programs}/store/home.ssh.personal.nix"
    ])
  );

}
