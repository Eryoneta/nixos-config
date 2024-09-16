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
      ++ (searchFiles "${public.programs}" onlyHomeConfig onlyDefault onlyNixFile)
      ++ (searchFiles "${private.programs}" onlyHomeConfig onlyDefault onlyNixFile)
      # User specific
      ++ (searchFiles "${public.programs}" onlyHomeConfig onlyUser onlyNixFile)
      ++ (searchFiles "${private.programs}" onlyHomeConfig onlyUser onlyNixFile)
    )
  );

}
