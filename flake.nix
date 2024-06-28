{
    # Description
    description = "Flake inicial";
    # Inputs
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    };
    # Outputs
    outputs = { self, nixpkgs, ... }@inputs: {
        nixosConfigurations.LiCo = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
            ];
        };
    };
}
