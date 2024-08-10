flakePath: (
  let

    # Domain Builder
    buildDomain = configPath: folders: absolutePaths: subfolder: (
      # MapAttr: { folder = ./folder; } -> { folder = basePath/folder; }
      builtins.mapAttrs (name: value: (
        (if (builtins.hasAttr name absolutePaths) then configPath else flakePath) + subfolder + value
      )) folders
    );

  in {
    # Public-Private-Domains Builder
    buildFor = (
      let
        specialArg = configPath: folders: absolutePaths: {
          config-domain = {
            public = (buildDomain configPath folders absolutePaths "/public-config");
            private = (buildDomain configPath folders absolutePaths "/private-config");
          };
        };
      in {

        # Override Home-Manager-Module Configuration
        homeManagerModule = { configPath, folders, absolutePaths ? [] }: {
          home-manager = {
            sharedModules = [];
            extraSpecialArgs = (specialArg configPath folders absolutePaths);
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = { configPath, folders, absolutePaths ? [] }: {
          modules = [];
          extraSpecialArgs = (specialArg configPath folders absolutePaths);
        };

        # Override System Configuration
        nixosSystem = { configPath, folders, absolutePaths ? [] }: {
          modules = [];
          specialArgs = (specialArg configPath folders absolutePaths);
        };

      }
    );

}
)
