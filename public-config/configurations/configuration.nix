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

        # Path
        path = domain: type: (
          "${config-domain.${domain}.${"${type}s"}}/${paths.${"${domain}-${type}"}}"
        );

        # Response
        mkConditionalSymlink = domain: type: stopCondition: next: (
          if ((paths.${"${domain}-${type}"} or null) != null) then ( # Path is provided
            if (stopCondition) then ( # There is no other path
              (response domain type) # No other path provided = Return this regardless
            ) else (
              if (utils.pathExists (path domain type)) then ( # Path exists
                (response domain type) # Return this
              ) else next # Path non-existent = Check another path
            )
          ) else next # Path not provided = Check another path
        );
        # Note: Here, the argument "paths" will not have all the arguments from the input-set!
        #   Use "or null" to avoid errors. Calling the argument directly (That is, without "paths") is safe
        symlink = (utils.pipe "" (
          # Note: "pipe" builds the structure starting from the bottom. It requires the list to be reversed first
          utils.reverseList [
            # Note: In here, the list is upside down for readability

            # Dotfiles
            (x: mkConditionalSymlink "private" "dotfile" (public-dotfile == null && private-resource == null && public-resource == null) x)
            (x: mkConditionalSymlink "public" "dotfile" (private-resource == null && public-resource == null) x)

            # Resources
            (x: mkConditionalSymlink "private" "resource" (public-resource == null) x)
            (x: mkConditionalSymlink "public" "resource" (true) x)

            # Empty
            (x: {})

          ]
          # Note: It returns the first valid path. It does not check if it exits
          #   It only checks if it exists if there is other paths, then it returns it or tries the other paths
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

        # Response
        mkConditionalPath = domain: type: next: (
          if ((paths.${"${domain}-${type}"} or null) != null) then ( # Path is provided
            if (domain == "default") then (
              paths.${"${domain}-${type}"}
            ) else (
              if ((paths.${"default-${type}"} or null) != null) then ( # With default = A final value will be given
                if (condition domain type) then ( # Path exists
                  (response domain type)
                ) else next
              ) else ( # No default = Value can be non-existent
                utils.mkIfElse (condition domain type) ( # Path exists
                  (response domain type)
                ) next
              )
            )
          ) else next
        );
        # Note: Here, the argument "paths" will not have all the arguments from the input-set!
        #   Use "or null" to avoid errors. Calling the argument directly (That is, without "paths") is safe
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
          #   If "default-*" is given, it uses "if then else". This is for Nix functions
          #   If "default-*" is not given, it uses "mkIfElse". This is for NixOS/Home-Manager options
        ));

      in path
    );

    # Creates a valid Home-Manager/XDG symlink
    attr.mkSymlink = {
      private-dotfile ? null, public-dotfile ? null,
      private-resource ? null, public-resource ? null,
      ...
    }@extraConfigs: (
      let

        # Symlink
        symlink = (attr._mkGenericSymlink {
          response = domain: type: {
            enable = (attr.isDomainLoaded domain "${type}s");
            source = "${config-domain.${domain}.${"${type}s"}}/${extraConfigs.${"${domain}-${type}"}}"; # Read-only
          };
        } extraConfigs);

      in (
        if (symlink != {}) then (
          symlink // (builtins.removeAttrs extraConfigs [
            "public-dotfile" "private-dotfile"
            "public-resource" "private-resource"
          ])
          # Note: "extraConfigs" allows to include more options into the final set
        ) else {}
      )
    );

    # Creates a valid Home-Manager/XDG symlink to a file outside the Nix Store
    attr.mkOutOfStoreSymlink = {
      private-dotfile ? null, public-dotfile ? null,
      private-resource ? null, public-resource ? null,
      ...
    }@extraConfigs: (
      let

        # Out of store symlink
        outOfStoreSymlink = (attr._mkGenericSymlink {
          response = domain: type: {
            enable = (attr.isDomainLoaded domain "${type}s");
            source = (
              let
                path = "${config-domain.${domain}.${"${type}s"}}/${extraConfigs.${"${domain}-${type}"}}";
              in (
                utils.mkIfElse (attr.isSymlinkOutOfStoreAllowed) (
                  (utils.mkOutOfStoreSymlink path) # Editable
                ) (
                  path # Read-only
                )
              )
            );
          };
        } extraConfigs);

      in (
        if (outOfStoreSymlink != {}) then (
          outOfStoreSymlink // (builtins.removeAttrs extraConfigs [
            "public-dotfile" "private-dotfile"
            "public-resource" "private-resource"
          ])
          # Note: "extraConfigs" allows to include more options into the final set
        ) else {}
      )
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
            ((attr.isAgenixSecretsLoaded domain) && paths.${domain} != "")
          );
          response = domain: type: (
            paths.${domain}
          );
        } {
          private-secret = private;
          public-secret = public;
          default-secret = default;
        });

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
    attr.isAgenixSecretsLoaded = domain: (
      ((attr.isDomainLoaded domain "secrets") && !host.system.virtualDrive)
      # Note: A VM do not have access to stuff outside it. This breaks Agenix secrets
    );
    attr.isSymlinkOutOfStoreAllowed = (
      (!host.system.virtualDrive)
      # Note: A VM do not have access to stuff outside it. This includes symlinks outside the Nix Store
    );

  };

}
