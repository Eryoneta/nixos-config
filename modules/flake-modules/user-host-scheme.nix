# User & Host Scheme
# Defines "user" OR "host" inside "specialArgs" or "extraSpecialArgs" (NixOS gets "host", Home-Manager gets "user")
# "host" have a atribute "user", and "user" have a atribute "host". One points to the other (Ex.: User -> Host -> User -> void)
# It can carry useful atributes like "system" or "username", and custom atributes if necessary
# (The "user" or "host" passed in the arguments can have extra atributes!)
# Also, is expected some folders to exist (Ex.: User = "me", then "/nix/store/.../users/me/home.nix" have to exist)
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
    buildPair = user: host: {
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