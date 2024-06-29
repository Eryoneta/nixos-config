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
    outputs = inputs@{ nixpkgs, home-manager, ... }: {
        nixosConfigurations = {
            LiCo = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix
                    home-manager.nixosModules.home-manager {
                        home-manager = {
                          useGlobalPkgs = true;
                          useUserPackages = true;
                          users.yo = import ./home/home.nix;
                        };
                    }
                ];
            };
        };
    };
}
