# Public/Private Domains
/*
  - A flake-module modifier
  - Defines a "config-domain" inside "specialArgs" or "extraSpecialArgs"
    - It contains paths
  - The configuration is separated into two "domains": Public and Private
    - That requires two folders at the "flake.nix" level: "private-config" and "public-config"
    - The content can be defined by the set "folders". Each atribute gets turned into a path for a folder
  - Some folders can be set as absolute, meaning its path does not point to "/nix/store", but to "configPath"
  - Ex.: ''
    (public-private-domains.build {
      configPath = "/home/user/.nixos-config";
      folders = {
        dotfiles = "/dotfiles"; # All paths are strings!
        resources = "/resources";
        programs = "/programs";
      };
      absolutePaths.dotfiles = true;
      absolutePaths.resources = true;
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
        home.file."program".source = with config-domain; (
          config.lib.file.mkOutOfStoreSymlink "${private.dotfiles}/program"
        );
        # ...
      }
    ''
  - With this configuration, "private-config" can be a private git submodule, only loaded with the right credentials
    - But this requires checking if the wanted folder is present before using it, or the unloaded sudmodule can break the configuration
*/
flakePath: (
  let

    # Domain Builder
    buildDomain = configPath: folders: absolutePaths: subfolder: (
      # MapAttr: { folder = ./folder; } -> { folder = basePath/folder; }
      builtins.mapAttrs (name: value: (
        (if (builtins.hasAttr name absolutePaths) then configPath else flakePath) + subfolder + value
      )) folders
    );

    # SpecialArg
    specialArg = configPath: folders: absolutePaths: {
      config-domain = {
        public = (buildDomain configPath folders absolutePaths "/public-config");
        private = (buildDomain configPath folders absolutePaths "/private-config");
      };
    };

  in {
    # Builder
    build = { configPath, folders, absolutePaths ? [] }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg configPath folders absolutePaths);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg configPath folders absolutePaths);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg configPath folders absolutePaths);
      };

    };
  }
)