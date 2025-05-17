{ ... }@args: with args.config-utils; {
    
  # Programs
  imports = (
    let
      onlySystemConfig = ".nixos.";
      onlyDefault = ".default.";
      onlyHost = ".${args.hostArgs.hostname}.";
      onlyNixFile = ".nix";
    in with args.config-domain; (
      []
      # Default
      ++ (utils.searchFiles "${public.programs}" "" [ onlySystemConfig onlyDefault ] onlyNixFile)
      # Host specific
      ++ (utils.searchFiles "${public.programs}" "" [ onlySystemConfig onlyHost ] onlyNixFile)
      ++ (
        # Check for "./private-config/programs"
        if (utils.pathExists private.programs) then (
          []
          # Default
          ++ (utils.searchFiles "${private.programs}" "" [ onlySystemConfig onlyDefault ] onlyNixFile)
          # Host specific
          ++ (utils.searchFiles "${private.programs}" "" [ onlySystemConfig onlyHost ] onlyNixFile)
        ) else []
      )
    )
  );

}
