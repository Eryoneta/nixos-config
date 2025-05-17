# User & Host Scheme
/*
  - A flake-module modifier
  - Defines "hostArgs" inside "specialArgs" and "userArgs" inside "extraSpecialArgs"
    - Basically, NixOS gets "hostArgs" and Home-Manager gets "usersArgs" and "userDevArgs"
  - "hostArgs" have a atribute "usersArgs", and each "usersArgs" have a atribute "hostArgs"
    - One points to the other recursively
      - Ex.: "hostArgs.userDev.host.userDev.host.userDev.username" is totally valid
  - Both "users" and "host" need to be created before
    - "buildHost" returns a valid "host"
    - "buildUser" returns a valid "user" to be included in a list
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
      Users = [ User1 ];
    in {
      nixosConfigurations = {
        flake-modules."nixos-system.nix".build {
          architecture = Machine1.system.architecture;
          package = inputs.nixpkgs;
          modifiers = [
            # ...
            (user-host-scheme.build {
              users = Users;
              host = Machine1;
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
        userDev = default.user;
        users = [ default.user ];
        system = {
          architecture = "x86_64-linux";
          label = "";
        };
        configFolder = "/etc/nixos";
        configFolderNixStore = flakePath; # Note: A flake gets copied into the NixStore before evaluation
      };

      # Default User
      user = {
        username = "nixos";
        name = "nixos";
        host = default.host;
        configFolder = default.host.configFolder;
        configDevFolder = "";
      };

    };

    # Host-Users-Group Builder
    buildGroup = userDev: users: host: (
      let
        userDevGroup = userDev // {
          host = hostGroup;
        };
        usersGroup = (builtins.map (user: (
          user // {
            host = hostGroup;
          }
        )) users);
        usersGroupSet = (builtins.listToAttrs (builtins.map (user: {
          name = user.username;
          value = user;
        }) usersGroup));
        hostGroup = host // {
          userDev = userDevGroup;
          users = usersGroupSet;
          configFolder = userDevGroup.configFolder;
        };
      in {
        userDev = userDevGroup;
        users = usersGroupSet;
        host = hostGroup;
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
    build = { users ? [ default.user ], host ? default.host }: (
      let
        userDev = (builtins.head users);
        group = (buildGroup userDev users host);
      in {

        # Override Home-Manager-Module Configuration
        homeManagerModule = {
          home-manager = {
            users = (builtins.mapAttrs (
              username: user: (import "${flakePath}/users/${username}/home.nix")
            ) group.users);
            extraSpecialArgs = {
              userDevArgs = group.userDev;
              usersArgs = group.users;
            };
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = username: {
          modules = [
            "${flakePath}/users/${username}/home.nix"
          ];
          extraSpecialArgs = {
            userDevArgs = group.userDev;
            usersArgs = group.users;
          };
        };

        # Override System Configuration
        nixosSystem = {
          modules = [
            "${flakePath}/hosts/${group.host.hostname}/configuration.nix"
          ];
          specialArgs = {
            hostArgs = group.host;
          };
        };

      }
    );

  }
)