# Public/Private Domains
/*
  - A flake-module modifier
  - Defines a "config-domain" inside "specialArgs" or "extraSpecialArgs"
    - It contains paths
  - The configuration is separated into two "domains": Public and Private
    - That requires two directories at the "flake.nix" level: "./private-config" and "./public-config"
    - The content can be defined by the set "directories". Each atribute gets turned into a path for a directory
  - Absolute paths can be read from the "outOfStore" set
  - Ex.: ''
    (public-private-domains.build {
      configPath = "/home/user/.nixos-config";
      directories = {
        dotfiles = "/dotfiles"; # All paths are strings!
        programs = "/programs";
      };
    })
  ''
    - Ex.: ''
      { config-domain, ... }: {
        imports = [
          "${config-domain.public.programs}/my-file.nix"
          "${config-domain.private.programs}/my-private-file.nix"
        ];
        # ...
      }
    ''
    - Ex.: "mkOutOfStoreSymlink" requires absolute paths: ''
      { config, config-domain, ... }: {
        # ...
        home.file."random-program".source = (
          config.lib.file.mkOutOfStoreSymlink "${config-domain.outOfStore.private.dotfiles}/random-program"
        );
        # ...
      }
    ''
  - With this configuration, "./private-config" can be a private git submodule, only loaded with the right credentials
    - But this requires checking if the wanted directory is present before using it, or the unloaded sudmodule can break the configuration!
*/
flakePath: (
  let

    # Domain Builder
    buildDomain = configPath: directories: outOfStore: subdirectory: (
      # MapAttr: { directory = "/directory"; } -> { directory = "basePath/directory"; }
      builtins.mapAttrs (name: value: (
        (if (outOfStore) then configPath else flakePath) + subdirectory + value
      )) directories
    );

  in {

    # Args Builder
    buildSpecialArgs = { configPath, directories }: {
      config-domain = {
        public = (buildDomain configPath directories false "/public-config");
        private = (buildDomain configPath directories false "/private-config");
        outOfStore = {
          public = (buildDomain configPath directories true "/public-config");
          private = (buildDomain configPath directories true "/private-config");
        };
      };
    };

  }
)