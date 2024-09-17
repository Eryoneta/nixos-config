{ tools, config-domain, user, ... }: with tools; {
    
  # Programs
  imports = (
    let
      onlyHomeConfig = "home.";
      onlyDefault = ".default.";
      onlyUser = ".${user.username}.";
      onlyNixFile = ".nix";
    in with config-domain; (
      []
      # Default
      ++ (mkFunc.searchFiles "${public.programs}" onlyHomeConfig onlyDefault onlyNixFile)
      ++ (mkFunc.searchFiles "${private.programs}" onlyHomeConfig onlyDefault onlyNixFile)
      # User specific
      ++ (mkFunc.searchFiles "${public.programs}" onlyHomeConfig onlyUser onlyNixFile)
      ++ (mkFunc.searchFiles "${private.programs}" onlyHomeConfig onlyUser onlyNixFile)
    )
  );

}
