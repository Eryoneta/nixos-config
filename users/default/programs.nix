{ ... }: {
    
  # Default
  imports = let
    programsPath = ../../public-config/programs;
  in [
    (programsPath + /basic-programs.nix)
    (programsPath + /store/firefox.nix)
    (programsPath + /store/vscodium.nix)
  ];

}
