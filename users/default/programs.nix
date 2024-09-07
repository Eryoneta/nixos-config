{ config-domain, modules, user, lib, ... }: {
    
  # Programs
  imports = (
    let
      listFiles = (import modules.nix-modules."listFiles.nix" lib).listFiles;
      onlyHomeConfig = "home.";
      onlyDefault = ".default.";
      onlyUser = ".${user.username}.";
      onlyNixFile = ".nix";
    in with config-domain; (
      []
      # Public, default
      ++ (listFiles "${public.programs}" onlyHomeConfig onlyDefault onlyNixFile)
      ++ (listFiles "${public.programs}/store" onlyHomeConfig onlyDefault onlyNixFile)
      # Private, default
      ++ (listFiles "${private.programs}" onlyHomeConfig onlyDefault onlyNixFile)
      ++ (listFiles "${private.programs}/store" onlyHomeConfig onlyDefault onlyNixFile)
      # Public, hostname
      ++ (listFiles "${public.programs}" onlyHomeConfig onlyUser onlyNixFile)
      ++ (listFiles "${public.programs}/store" onlyHomeConfig onlyUser onlyNixFile)
      # Private, hostname
      ++ (listFiles "${private.programs}" onlyHomeConfig onlyUser onlyNixFile)
      ++ (listFiles "${private.programs}/store" onlyHomeConfig onlyUser onlyNixFile)
    )
  );

}
