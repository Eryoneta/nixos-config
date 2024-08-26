{ config-domain, ... }: {
    
  # Yo
  imports = (
    (with config-domain.public; [
      "${programs}/store/git.nix"
      "${programs}/store/calibre.nix"
    ])
    ++
    (with config-domain.private; [
      "${programs}/other-programs.nix"
    ])
  );

}
