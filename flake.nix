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
            defaultUser = {
                username = "nixos";
                name = "nixos";
                dotFolder = "";
            };
            defaultHost = {
                system = "x86_64-linux";
                hostname = "nixos";
                name = "nixos";
                user = defaultUser;
            };
            # Builders
            systemBuild = host: inputs.nixpkgs.lib.nixosSystem {
                system = host.system;
                modules = [
                    (./. + "./hosts/${host.hostname}/configuration.nix")
                ];
                specialArgs = {
                    inherit host;
                };

            };
            homeManagerBuild = user: inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${defaultHost.system};
                modules = [
                    (./. + "/users/${user.username}/home.nix")
                ];
                extraSpecialArgs = {
                    inherit user;
                };
            };
            # Dotfiles
            dotFolderPathBuild = user: flakePath: "/home/${user.username}/${flakePath}/users/${user.username}/dotfiles";
        in
            let
                # Users
                Yo = defaultUser // {
                    username = "yo";
                    name = "Yo";
                    dotFolder = dotFolderPathBuild Yo "Utilities/SystemConfig/nixos-config";
                };
                # Hosts
                LiCo = defaultHost // {
                    hostname = "lico";
                    name = "LiCo";
                    user = Yo;
                };
                NeLiCo = defaultHost // {
                    hostname = "nelico";
                    name = "NeLiCo";
                    user = Yo;
                };
            in {
                # NixOS
                nixosConfigurations = {
                    LiCo = systemBuild LiCo;
                    NeLiCo = systemBuild NeLiCo;
                };
                # Home Manager
                homeConfigurations = {
                    Yo = homeManagerBuild Yo;
                };
        };
}
