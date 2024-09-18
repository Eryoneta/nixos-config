{ config-domain, user, ... }@args: with args.config-utils; {
    
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
      # Host specific
      ++ (mkFunc.searchFiles "${public.programs}" onlyHomeConfig onlyUser onlyNixFile)
      ++ (
        # Private
        if (mkFunc.pathExists private.programs) then
          []
          # Default
          ++ (mkFunc.searchFiles "${private.programs}" onlyHomeConfig onlyDefault onlyNixFile)
          # Host specific
          ++ (mkFunc.searchFiles "${private.programs}" onlyHomeConfig onlyUser onlyNixFile)
        else []
      )
    )
  );

}
