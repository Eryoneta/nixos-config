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
            buildSystem = host: inputs.nixpkgs.lib.nixosSystem {
                system = host.system.architecture;
                modules = [
                    (./. + "/hosts/${host.hostname}/configuration.nix")
                ];
                specialArgs = {
                    inherit host;
                };

            };
            buildHomeManager = user: inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${user.host.system.architecture};
                modules = [
                    (./. + "/users/${user.username}/home.nix")
                ];
                extraSpecialArgs = {
                    inherit user;
                };
            };
            buildHost = user: host: defaultHost // {
                hostname = host.hostname;
                name = host.name;
                system = defaultHost.system // {
                    label = host.system.label;
                };
                user = user;
                configFolder = user.configFolder;
            };
            buildUser = host: user: defaultUser // {
                username = user.username;
                name = user.name;
                host = host;
                configFolder = user.configFolder;
                dotFolder = buildDotFolderPath user.username user.configFolder;
            };
            buildDotFolderPath = username: configFolderPath: "${configFolderPath}/users/${username}/dotfiles";
        in
            let
                # Hosts
                LiCo = user: buildHost user {
                    hostname = "lico";
                    name = "LiCo";
                    system.label = "Config_Organization:_Reordem"; #[a-zA-Z0-9:_.-]*
                };
                NeLiCo = user: buildHost user {
                    hostname = "nelico";
                    name = "NeLiCo";
                    system.label = ""; #[a-zA-Z0-9:_.-]*
                };
                # Users
                Yo = host: buildUser host {
                    username = "yo";
                    name = "Yo";
                    configFolder = "/home/yo/Utilities/SystemConfig/nixos-config";
                };
            in {
                # NixOS
                nixosConfigurations = {
                    "Yo@LiCo" = buildSystem (LiCo (Yo { }));
                    "Yo@NeLiCo" = buildSystem (NeLiCo (Yo { }));
                };
                # Home Manager
                homeConfigurations = {
                    "Yo@LiCo" = buildHomeManager (Yo (LiCo { }));
                };
            };
}
