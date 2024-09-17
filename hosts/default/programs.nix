{ config-domain, modules, host, lib, ... }@args: with args.config-utils; {
    
  # Programs
  imports = (
    let
      onlySystemConfig = "nixos.";
      onlyDefault = ".default.";
      onlyHost = ".${host.hostname}.";
      onlyNixFile = ".nix";
    in with config-domain; (
      []
      # Default
      ++ (mkFunc.searchFiles "${public.programs}" onlySystemConfig onlyDefault onlyNixFile)
      ++ (mkFunc.searchFiles "${private.programs}" onlySystemConfig onlyDefault onlyNixFile)
      # Host specific
      ++ (mkFunc.searchFiles "${public.programs}" onlySystemConfig onlyHost onlyNixFile)
      ++ (mkFunc.searchFiles "${private.programs}" onlySystemConfig onlyHost onlyNixFile)
    )
  );

}
