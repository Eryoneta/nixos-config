{ config-domain, ... }@args: with args.config-utils; { # (Setup Module)

  # Import ALL Setup modules
  imports = (
    let
      onlyNixFile = ".nix";
      searchNixFiles = path: (utils.searchFiles path "" "" onlyNixFile);
    in with config-domain; (
      builtins.concatLists [
        (searchNixFiles ./hosts)
        (searchNixFiles ./users)
        (searchNixFiles "${public.configurations}")
        (searchNixFiles "${public.programs}")
        (
          # Check for "./private-config/configurations"
          if (utils.pathExists private.configurations) then (
            (searchNixFiles "${private.configurations}")
          ) else []
        )
        (
          # Check for "./private-config/programs"
          if (utils.pathExists private.programs) then (
            (searchNixFiles "${private.programs}")
          ) else []
        )
      ]
    )
  );

}
