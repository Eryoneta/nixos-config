{
  # Description
  description = "Yo Flake";
  # Inputs
  inputs = {

    # NixOS (AutoUpgrade)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home-Manager (AutoUpgrade)
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Stable Packages (AutoUpgrade)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Unstable Packages (AutoUpgrade)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Unstable Packages (Manual Upgrade)
    nixpkgs-unstable-fixed.url = "github:NixOS/nixpkgs/nixos-unstable";

  };
  # Outputs
  outputs = { self, ... }@extraArgs: (
    # let 
    #   ...packages...
    # in (
    #   let
    #     ...defaults & builders...
    #   in (
    #     let
    #       ...hosts & users...
    #     in (
    #       ...configurations...
    #     )
    #   )
    # )
    let

      # Sistema
      nixpkgs = extraArgs.nixpkgs;
      home-manager = extraArgs.home-manager;

      # Pacotes
      pkgsConfig = host: {
        system = host.system.architecture;
        config.allowUnfree = true;
      };
      buildPkgsBundle = host: {
        stable = (import extraArgs.nixpkgs-stable (pkgsConfig host));
        unstable = (import extraArgs.nixpkgs-unstable (pkgsConfig host));
        unstable-fixed = (import extraArgs.nixpkgs-unstable-fixed (pkgsConfig host));
      };
      
    in (
      let

        # Default Host
        defaultHost = {
          hostname = "nixos";
          name = "nixos";
          user = defaultUser;
          system = {
            architecture = "x86_64-linux";
            label = "";
          };
          configFolder = "/etc/nixos";
        };

        # Default User
        defaultUser = {
          username = "nixos";
          name = "nixos";
          host = defaultHost;
          dotFolder = "";
          configFolder = defaultHost.configFolder;
        };

        # System Builder
        buildSystem = pair: nixpkgs.lib.nixosSystem {
          system = pair.host.system.architecture;
          modules = [
            (./. + "/hosts/${pair.host.hostname}/configuration.nix")
            home-manager.nixosModules.home-manager {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${pair.user.username} = import (./. + "/users/${pair.user.username}/home.nix");
                extraSpecialArgs = {
                  user = pair.user;
                  pkgs-bundle = (buildPkgsBundle pair.host);
                };
              };
            }
          ];
          specialArgs = {
            host = pair.host;
            pkgs-bundle = (buildPkgsBundle pair.host);
          };
        };

        # Home-Manager Builder
        buildHomeManager = pair: home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${pair.host.system.architecture};
          modules = [
            (./. + "/users/${pair.user.username}/home.nix")
          ];
          extraSpecialArgs = {
            user = pair.user;
            pkgs-bundle = (buildPkgsBundle pair.host);
          };
        };

        # Host Builder
        buildHost = host: defaultHost // {
          hostname = host.hostname;
          name = host.name;
          system = defaultHost.system // {
            label = host.system.label;
          };
        };

        # User Builder
        buildUser = user: defaultUser // {
          username = user.username;
          name = user.name;
          configFolder = user.configFolder;
          dotFolder = buildDotFolderPath user.username user.configFolder;
        };
        buildDotFolderPath = username: configFolderPath: "${configFolderPath}/users/${username}/dotfiles";

        # Host-User-Pair Builder
        buildPair = host: user: {
          user = user // {
            host = host // {
              user = user; # User -> Host -> User -> void
              configFolder = user.configFolder;
            };
          };
          host = host // {
            user = user // {
              host = host; # Host -> User -> Host -> void
            };
            configFolder = user.configFolder;
          };
        };

      in (
        let

          # Hosts
          LiCo = buildHost {
            hostname = "lico";
            name = "LiCo";
            system.label = "Config_Organization:_Default_Reordem"; #[a-zA-Z0-9:_.-]*
          };
          NeLiCo = buildHost {
            hostname = "nelico";
            name = "NeLiCo";
            system.label = ""; #[a-zA-Z0-9:_.-]*
          };

          # Users
          Yo = buildUser {
            username = "yo";
            name = "Yo";
            configFolder = "/home/yo/Utilities/SystemConfig/nixos-config";
          };

        in {

          # NixOS + Home Manager
          nixosConfigurations = {
            "Yo@LiCo" = buildSystem (buildPair LiCo Yo);
            "Yo@NeLiCo" = buildSystem (buildPair NeLiCo Yo);
          };
          
          # Home Manager
          homeConfigurations = {
            "Yo@LiCo" = buildHomeManager (buildPair LiCo Yo);
          };

        }
      )
    )
  );
}
