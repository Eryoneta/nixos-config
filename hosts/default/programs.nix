{ config-domain, modules, host, lib, ... }: {
    
  # Programs
  imports = (
    let
      listFiles = (import modules.nix-modules."listFiles.nix" lib).listFiles;
      onlySystemConfig = "nixos.";
      onlyDefault = ".default.";
      onlyHost = ".${host.hostname}.";
      onlyNixFile = ".nix";
    in with config-domain; (
      []
      # Public, default
      ++ (listFiles "${public.programs}" onlySystemConfig onlyDefault onlyNixFile)
      ++ (listFiles "${public.programs}/store" onlySystemConfig onlyDefault onlyNixFile)
      # Private, default
      ++ (listFiles "${private.programs}" onlySystemConfig onlyDefault onlyNixFile)
      ++ (listFiles "${private.programs}/store" onlySystemConfig onlyDefault onlyNixFile)
      # Public, hostname
      ++ (listFiles "${public.programs}" onlySystemConfig onlyHost onlyNixFile)
      ++ (listFiles "${public.programs}/store" onlySystemConfig onlyHost onlyNixFile)
      # Private, hostname
      ++ (listFiles "${private.programs}" onlySystemConfig onlyHost onlyNixFile)
      ++ (listFiles "${private.programs}/store" onlySystemConfig onlyHost onlyNixFile)
    )
  );

  # Pacotes
  config.nixpkgs.config.allowUnfree = true; # Precaução

}
