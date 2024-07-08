{
    # Description
    description = "Yo Flake";
    # Inputs
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-24.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
    # Outputs
    outputs = inputs@{ self, ... }:
        let
            # Defaults
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
            defaultUser = {
                username = "nixos";
                name = "nixos";
                host = defaultHost;
                dotFolder = "";
                configFolder = defaultHost.configFolder;
            };
            # Builders
            buildSystem = pair: inputs.nixpkgs.lib.nixosSystem {
                system = pair.host.system.architecture;
                modules = [
                    (./. + "/hosts/${pair.host.hostname}/configuration.nix")
                    inputs.home-manager.nixosModules.home-manager {
                        home-manager = {
                            useGlobalPkgs = true;
                            useUserPackages = true;
                            users.${pair.user.username} = import (./. + "/users/${pair.user.username}/home.nix");
                            extraSpecialArgs = {
                                user = pair.user;
                            };
                        };
                    }
                ];
                specialArgs = {
                    host = pair.host;
                };

            };
            buildHomeManager = pair: inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${pair.host.system.architecture};
                modules = [
                    (./. + "/users/${pair.user.username}/home.nix")
                ];
                extraSpecialArgs = {
                    user = pair.user;
                };
            };
            buildHost = host: defaultHost // {
                hostname = host.hostname;
                name = host.name;
                system = defaultHost.system // {
                    label = host.system.label;
                };
            };
            buildUser = user: defaultUser // {
                username = user.username;
                name = user.name;
                configFolder = user.configFolder;
                dotFolder = buildDotFolderPath user.username user.configFolder;
            };
            buildDotFolderPath = username: configFolderPath: "${configFolderPath}/users/${username}/dotfiles";
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
        in
            let
                # Hosts
                LiCo = buildHost {
                    hostname = "lico";
                    name = "LiCo";
                    system.label = "Config_Organization:_Dual_Manager_Teste"; #[a-zA-Z0-9:_.-]*
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
            };
}
