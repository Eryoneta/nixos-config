# Public/Private Domains
# Defines two domains: Public and Private
# The folder content can be defined by a set "folders". Each atribute gets turned into a path for a folder
# Some folders can be set as absolute, meaning its path doesn't point to "/nix/store"
# All paths are available in "config-domain", inside "specialArgs" or "extraSpecialArgs"
# Ex.: The input set "{
#   configPath = "/home/user/nixos-config";
#   folders = { subfolder1 = "./f1"; subfolder2 = "./f2"; };
#   absolutePaths.subfolder2 = true;
# }" results in "config-domain = {
#   public = { subfolder1 = "/nix/store/.../f1"; subfolder2 = "/home/user/nixos-config/f2"; };
# };" available in "specialArgs" or "extraSpecialArgs"
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
            extraSpecialArgs = (specialArg configPath folders absolutePaths);
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = { configPath, folders, absolutePaths ? [] }: {
          extraSpecialArgs = (specialArg configPath folders absolutePaths);
        };

        # Override System Configuration
        nixosSystem = { configPath, folders, absolutePaths ? [] }: {
          specialArgs = (specialArg configPath folders absolutePaths);
        };

      }
    );

}
)
