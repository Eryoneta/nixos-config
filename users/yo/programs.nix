{ ... }: {
    
  # Yo
  imports = let
    programsPath = ../../public-config/programs;
  in [
    (programsPath + /store/git.nix)
    (programsPath + /store/calibre.nix)
  ];

}
