username: { config, config-domain, ... }@args: with args.config-utils; { # Note: This is a NixOSModule within a Nix function!

  # Programs
  imports = (
    let
      onlyHomeConfig = ".home.";
      onlyDefault = ".default.";
      onlyUser = ".${username}.";
      onlyNixFile = ".nix";
    in with config-domain; (
      []
      # Default
      ++ (utils.searchFiles "${public.programs}" "" [ onlyHomeConfig onlyDefault ] onlyNixFile)
      # Host specific
      ++ (utils.searchFiles "${public.programs}" "" [ onlyHomeConfig onlyUser ] onlyNixFile)
      ++ (
        # Check for "./private-config/programs"
        if (utils.pathExists private.programs) then (
          []
          # Default
          ++ (utils.searchFiles "${private.programs}" "" [ onlyHomeConfig onlyDefault ] onlyNixFile)
          # Host specific
          ++ (utils.searchFiles "${private.programs}" "" [ onlyHomeConfig onlyUser ] onlyNixFile)
        ) else []
      )
    )
  );

}
