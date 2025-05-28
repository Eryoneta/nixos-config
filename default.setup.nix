{ ... }@args: with args.config-utils; { # (Setup Module)

  # Import ALL Setup modules
  imports = (
    let
      onlySetupConfig = ".setup.";
      onlyNixFile = ".nix";
      listFiles = path: (utils.searchFiles path "" [ onlySetupConfig ] onlyNixFile);
    in with args.config-domain; (
      builtins.concatLists [
        (listFiles ./hosts)
        (listFiles ./users)
        (listFiles "${public.programs}")
        (
          # Check for "./private-config/programs"
          if (utils.pathExists private.programs) then (
            (listFiles "${private.programs}")
          ) else []
        )
      ]
    )
  );

}
