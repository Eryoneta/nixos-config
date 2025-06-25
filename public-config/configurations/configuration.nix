{ config-domain, host, ... }@args: with args.config-utils; { # (Setup Module)

  # Configuration
  config.modules."configuration" = rec {
    tags = [ "core-setup" ];

    # Internal function, creates a symlink
    attr._mkGenericSymlink = {
      response ? (domain: type: {})
    }: {
      private-dotfile ? null, public-dotfile ? null,
      private-resource ? null, public-resource ? null,
      ...
    }@paths: (
      let

        # Order of priority:
        /*
          private-dotfile
          public-dotfile
          private-resource
          public-resource
        */

        # Note: Here, the argument "paths" will not have all the arguments from the input-set!
        #   Use "or null" to avoid errors. Calling the argument directly (That is, without "paths") is safe

        # Response
        mkConditionalSymlink = domain: type: next: (
          let
            path = domain: type: (
              "${config-domain.${domain}.${"${type}s"}}/${paths.${"${domain}-${type}"}}"
            );
          in (
            if ((paths.${"${domain}-${type}"} or null) != null) then ( # Path is provided
              { # Switch case
                "private" = (
                  if (utils.pathExists (path domain type)) then ( # Path exists
                    (response domain type)
                  ) else (
                    if ((paths.${"public-${type}"} or null) != null) then ( # There is another
                      next
                    ) else ( # There is no other path
                      utils.mkIf (false) ( # Path is not acceptable
                        (response domain type)
                      )
                    )
                  )
                );
                "public" = (
                  if (utils.pathExists (path domain type)) then ( # Path is acceptable
                    (response domain type)
                  ) else (
                    utils.mkIf (false) ( # Path is not acceptable
                      (response domain type)
                    )
                  )
                );
              }.${domain}
            ) else next # Path not provided = Check another path
          )
        );
        symlink = (utils.pipe "" (
          # Note: "pipe" builds the structure starting from the bottom. It requires the list to be reversed first
          utils.reverseList [
            # Note: In here, the list is upside down for readability

            # Dotfiles
            (x: mkConditionalSymlink "private" "dotfile" x)
            (x: mkConditionalSymlink "public" "dotfile" x)

            # Resources
            (x: mkConditionalSymlink "private" "resource" x)
            (x: mkConditionalSymlink "public" "resource" x)

            # Empty
            (x: {})

          ]
          # Note: It returns the first valid path
          #   It might also return "mkIf (false) (...)" if there is no valid path
        ));

      in symlink
    );

    # Internal function, creates a path, given a condition and reponse formats
    attr._mkGenericPath = {
      condition ? (domain: type: true), response ? (domain: type: true)
    }: {
      private-resource ? null, public-resource ? null, default-resource ? null,
      private-secret ? null, public-secret ? null, default-secret ? null,
      private-dotfile ? null, public-dotfile ? null, default-dotfile ? null
    }@paths: ( # ...Overkill? A bit too much? It works tho
      let

        # Order of priority:
        /*
          private-resource
          public-resource
          default-resource
          private-secret
          public-secret
          default-secret
          private-dotfile
          public-dotfile
          default-dotfile
        */

        # Combinations:
        /*
          private                       "mkIf" with the path
          private + public              "mkIf" with either a public or private path
          private + default             Final value with either a private or default path
          private + public + default    Final value with either a private, public, or default path
          public                        "mkIf" with the path
          public + default              Final value with either a public or default path
          default                       Final value with the path
        */

        # Note: Here, the argument "paths" will not have all the arguments from the input-set!
        #   Use "or null" to avoid errors. Calling the argument directly (That is, without "paths") is safe

        # Response
        mkConditionalPath = domain: type: next: (
          if ((paths.${"${domain}-${type}"} or null) != null) then ( # Path is provided
            { # Switch case
              "private" = (
                if (condition domain type) then ( # Path is acceptable
                  (response domain type)
                ) else (
                  if ((paths.${"public-${type}"} or paths.${"default-${type}"} or null) != null) then ( # There is others
                    next
                  ) else ( # There is no other path
                    utils.mkIf (false) ( # Path is not acceptable
                      (response domain type)
                    )
                  )
                )
              );
              "public" = (
                if (condition domain type) then ( # Path is acceptable
                  (response domain type)
                ) else (
                  if ((paths.${"default-${type}"} or null) != null) then ( # There is another
                    next
                  ) else ( # There is no other path
                    utils.mkIf (false) ( # Path is not acceptable
                      (response domain type)
                    )
                  )
                )
              );
              "default" = paths.${"${domain}-${type}"}; # Default path is always returned
            }.${domain}
          ) else next # Path not provided = Check another path
        );
        path = (utils.pipe "" (
          # Note: "pipe" builds the structure starting from the bottom. It requires the list to be reversed first
          utils.reverseList [
            # Note: In here, the list is upside down for readability

            # Resources
            (x: (mkConditionalPath "private" "resource" x))
            (x: (mkConditionalPath "public" "resource" x))
            (x: (mkConditionalPath "default" "resource" x))

            # Secrets
            (x: (mkConditionalPath "private" "secret" x))
            (x: (mkConditionalPath "public" "secret" x))
            (x: (mkConditionalPath "default" "secret" x))

            # Dotfiles
            (x: (mkConditionalPath "private" "dotfile" x))
            (x: (mkConditionalPath "public" "dotfile" x))
            (x: (mkConditionalPath "default" "dotfile" x))

            # Empty
            (x: "")

          ]
          # Note: It returns the first valid path
          #   If "default-*" is given, it returns a final value
          #   If "default-*" is not given, it might return "mkIf (false) (...)" if there is no valid path
          #     This is for NixOS/Home-Manager options
        ));

      in path
    );

    # Creates a valid Home-Manager/XDG symlink
    attr.mkSymlink = {
      private-dotfile ? null, public-dotfile ? null,
      private-resource ? null, public-resource ? null,
      ...
    }@paths: (
      let

        # Extra symlinks options
        extraConfigs = paths;

        # Symlink
        symlink = (attr._mkGenericSymlink {
          response = domain: type: ({
            enable = (attr.isDomainLoaded domain "${type}s");
            source = "${config-domain.${domain}.${"${type}s"}}/${paths.${"${domain}-${type}"}}"; # Read-only
          } // (builtins.removeAttrs extraConfigs [
            "public-dotfile" "private-dotfile"
            "public-resource" "private-resource"
          ]));
          # Note: "extraConfigs" allows to include more options into the final set
        } paths);

      in symlink
    );

    # Creates a valid Home-Manager/XDG symlink to a file outside the Nix Store
    attr.mkOutOfStoreSymlink = {
      private-dotfile ? null, public-dotfile ? null,
      private-resource ? null, public-resource ? null,
      ...
    }@paths: (
      let

        # Extra symlinks options
        extraConfigs = paths;

        # Out of store symlink
        outOfStoreSymlink = (attr._mkGenericSymlink {
          response = domain: type: ({
            enable = (attr.isDomainLoaded domain "${type}s");
            source = (
              let
                domainInStore = config-domain.${domain}.${"${type}s"};
                domainOutOfStore = config-domain.outOfStore.${domain}.${"${type}s"};
                pathInStore = "${domainInStore}/${paths.${"${domain}-${type}"}}";
                pathOutOfStore = "${domainOutOfStore}/${paths.${"${domain}-${type}"}}";
              in (
                utils.mkIfElse (attr.isSymlinkOutOfStoreAllowed) (
                  (utils.mkOutOfStoreSymlink pathOutOfStore) # Editable
                ) (
                  pathInStore # Read-only
                )
              )
            );
          } // (builtins.removeAttrs extraConfigs [
            "public-dotfile" "private-dotfile"
            "public-resource" "private-resource"
          ]));
          # Note: "extraConfigs" allows to include more options into the final set
        } paths);

      in outOfStoreSymlink
    );

    # Creates a path to a file
    attr.mkFilePath = {
      private-resource ? null, public-resource ? null, default-resource ? null,
      private-secret ? null, public-secret ? null, default-secret ? null,
      private-dotfile ? null, public-dotfile ? null, default-dotfile ? null
    }@paths: (
      let

        # Path
        filePath = (attr._mkGenericPath {
          condition = domain: type: (
            (utils.pathExists "${config-domain.${domain}.${"${type}s"}}/${paths.${"${domain}-${type}"}}")
          );
          response = domain: type: (
            "${config-domain.${domain}.${"${type}s"}}/${paths.${"${domain}-${type}"}}"
          );
        } paths);

      in filePath
    );

    # Creates a path to a Agenix secret
    attr.mkSecret = {
      private ? null, public ? null, default ? null
    }@paths: (
      let

        # Path
        secretPath = (attr._mkGenericPath {
          condition = domain: type: (
            ((attr.isAgenixSecretsAllowed domain) && paths.${domain} != "")
          );
          response = domain: type: (
            utils.mkIf ((attr.isAgenixSecretsAllowed domain) && paths.${domain} != "")
            paths.${domain}
          );
        } (utils.pipe paths [

          # Rename all arguments to be compliant with "attr._mkGenericPath"
          (x: (builtins.mapAttrs (domain: path: {
            name = "${domain}-secret";
            value = path;
          }) paths))

          # Transforms the set into a list
          (x: builtins.attrValues x)

          # Transforms the list into a set
          (x: builtins.listToAttrs x)

        ]));

      in secretPath
    );

    # Utilities to check if things are loaded
    attr.isDomainLoaded = domain: type: (
      { # Switch case
        "public" = { # Always loaded
          "configurations" = true;
          "programs" = true;
          "dotfiles" = true;
          "resources" = true;
          "secrets" = true;
          "*" = true;
        };
        "private" = {
          "configurations" = (utils.pathExists config-domain.private.configurations);
          "programs" = (utils.pathExists config-domain.private.programs);
          "dotfiles" = (utils.pathExists config-domain.private.dotfiles);
          "resources" = (utils.pathExists config-domain.private.resources);
          "secrets" = (utils.pathExists config-domain.private.secrets);
          "*" = (utils.pathExists config-domain.privatePath);
        };
      }.${domain}.${type}
    );
    attr.isAgenixSecretsAllowed = domain: (
      ((attr.isDomainLoaded domain "secrets") && !host.system.virtualDrive)
      # Note: A VM do not have access to stuff outside it. This breaks Agenix secrets
    );
    attr.isSymlinkOutOfStoreAllowed = (
      (!host.system.virtualDrive)
      # Note: A VM do not have access to stuff outside it. This includes symlinks outside the Nix Store
    );

  };

}
