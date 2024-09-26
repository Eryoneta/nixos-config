# User & Host Scheme
/*
  - A flake-module modifier
  - Defines "host" inside "specialArgs" and "user" inside "extraSpecialArgs"
    - Basically, NixOS gets "host" and Home-Manager gets "user"
  - "host" have a atribute "user", and "user" have a atribute "host"
    - One points to the other recursively
      - Ex.: "host.user.host.user.host.user.username" is totally valid
  - Both "user" and "host" need to be created before
    - "buildHost" returns a valid "host"
    - "buildUser" returns a valid "user"
    - Then, both need to be passed to "build" to be used
  - It can carry useful atributes like "system" or "username", and even custom atributes
  - Ex.: At "flake.nix": ''
    # ...
    let
      user-host-scheme = (import ./modules/flake-modules/user-host-scheme.nix self.outPath);
      Machine1 = user-host-scheme.buildHost {
        hostname = "machine1";
        name = "Machine 1";
      };
      User1 = user-host-scheme.buildUser {
        username = "user1";
        name = "User 1";
        configFolder = "/home/user1/.nixos-config";
      };
    in {
      nixosConfigurations = {
        flake-modules."nixos-system.nix".build {
          architecture = Machine1.system.architecture;
          package = inputs.nixpkgs;
          modifiers = [
            # ...
            (user-host-scheme.build {
              inherit User1;
              inherit Machine1;
            })
          ];
        }
      };
    }
    # ...
  ''
  - Also, is expected some folders to exist
    - Ex.: "./users/user1/home.nix" must exist
    - Ex.: "./hosts/machine1/configuration.nix" must exist
*/
flakePath: (
  let

    # Defaults
    default = {

      # Default Host
      host = {
        hostname = "nixos";
        name = "nixos";
        user = default.user;
        system = {
          architecture = "x86_64-linux";
          label = "";
        };
        configFolder = /etc/nixos;
        configFolderNixStore = flakePath;
      };

      # Default User
      user = {
        username = "nixos";
        name = "nixos";
        host = default.host;
        configFolder = default.host.configFolder;
      };

    };

    # Host-User-Pair Builder
    buildPair = user: host: (
      let
        userPair = user // {
          host = hostPair;
        };
        hostPair = host // {
          user = userPair;
          configFolder = user.configFolder;
        };
      in {
        user = userPair;
        host = hostPair;
      }
    );

  in {

    # Host Builder
    buildHost = host: (
      default.host // (host // {
        hostname = host.hostname;
        name = host.name;
        system = (default.host.system // host.system);
      })
    );

    # User Builder
    buildUser = user: (
      default.user // (user // {
        username = user.username;
        name = user.name;
        configFolder = user.configFolder;
      })
    );

    # Builder
    build = { user ? default.user, host ? default.host }: (
      let
        pair = (buildPair user host);
      in {

        # Override Home-Manager-Module Configuration
        homeManagerModule = {
          home-manager = {
            users.${pair.user.username} = (import "${flakePath}/users/${pair.user.username}/home.nix");
            extraSpecialArgs = {
              user = pair.user;
            };
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = {
          modules = [
            "${flakePath}/users/${pair.user.username}/home.nix"
          ];
          extraSpecialArgs = {
            user = pair.user;
          };
        };

        # Override System Configuration
        nixosSystem = {
          modules = [
            "${flakePath}/hosts/${pair.host.hostname}/configuration.nix"
          ];
          specialArgs = {
            host = pair.host;
          };
        };

      }
    );

  }
)