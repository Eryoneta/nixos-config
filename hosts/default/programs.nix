{ ... }: {

  # Default
  imports = let
    programsPath = ../../public-config/programs;
  in [
    (programsPath + /essential-programs.nix)
    (programsPath + /store/nix.nix)
    #(programsPath + /store/openssh.nix)
  ];

  # Pacotes
  config.nixpkgs.config.allowUnfree = true; # Precaução

}
