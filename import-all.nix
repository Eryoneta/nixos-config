{ config-domain, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Import ALL Setup modules
  imports = (
    let
      onlyNixFile = ".nix";
      searchNixFiles = path: (utils.searchFiles path "" "" onlyNixFile);
    in (
      builtins.concatLists [
        [ ./setups.nix ]
        (searchNixFiles ./hosts)
        (searchNixFiles ./users)
        (searchNixFiles "${config-domain.public.configurations}")
        (searchNixFiles "${config-domain.public.programs}")
        (
          # Check for "./private-config/configurations"
          if (utils.pathExists config-domain.private.configurations) then (
            (searchNixFiles "${config-domain.private.configurations}")
          ) else []
        )
        (
          # Check for "./private-config/programs"
          if (utils.pathExists config-domain.private.programs) then (
            (searchNixFiles "${config-domain.private.programs}")
          ) else []
        )
      ]
    )
  );

}
