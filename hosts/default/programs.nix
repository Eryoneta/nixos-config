{ config-domain, modules, host, lib, ... }: {
    
  # Programs
  imports = (
    let
      searchFiles = (import modules.nix-modules."searchFiles.nix" lib).searchFiles;
      onlySystemConfig = "nixos.";
      onlyDefault = ".default.";
      onlyHost = ".${host.hostname}.";
      onlyNixFile = ".nix";
    in with config-domain; (
      []
      # Default
      ++ (searchFiles "${public.programs}" onlySystemConfig onlyDefault onlyNixFile)
      ++ (searchFiles "${private.programs}" onlySystemConfig onlyDefault onlyNixFile)
      # Host specific
      ++ (searchFiles "${public.programs}" onlySystemConfig onlyHost onlyNixFile)
      ++ (searchFiles "${private.programs}" onlySystemConfig onlyHost onlyNixFile)
    )
  );

}
