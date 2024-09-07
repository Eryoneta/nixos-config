{ config-domain, modules, host, lib, ... }: {
    
  # Programs
  imports = (
    let
      listFiles = (import modules.nix-modules."listFiles.nix" lib).listFiles;
      prefix = "nixos.";
      infix = ".${host.hostname}.";
      suffix = ".nix";
    in with config-domain;(
      (listFiles "${public.programs}" prefix infix suffix)
      ++ (listFiles "${private.programs}" prefix infix suffix)
      ++ (listFiles "${public.programs}/store" prefix infix suffix)
      ++ (listFiles "${private.programs}/store" prefix infix suffix)
    )
  );

}
