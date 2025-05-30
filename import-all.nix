{ config-domain, ... }@args: with args.config-utils; { # (Setup Module)

  # Import ALL Setup modules
  imports = (
    let
      onlyNixFile = ".nix";
      listFiles = path: (utils.searchFiles path "" [] onlyNixFile);
    in with config-domain; (
      builtins.concatLists [
        (listFiles ./hosts)
        (listFiles ./users)
        (listFiles "${public.configurations}")
        (listFiles "${public.programs}")
        (
          # Check for "./private-config/configurations"
          if (utils.pathExists private.configurations) then (
            (listFiles "${private.configurations}")
          ) else []
        )
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
