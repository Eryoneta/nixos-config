{ config-domain, host, ... }@args: with args.config-utils; {
    
  # Programs
  imports = (
    let
      onlySystemConfig = ".nixos.";
      onlyDefault = ".default.";
      onlyHost = ".${host.hostname}.";
      onlyNixFile = ".nix";
    in with config-domain; (
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
