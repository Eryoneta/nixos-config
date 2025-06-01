# User/Host Scheme
/*
  - Contains three functions:
    - "buildHost" returns a host configuration
    - "buildUser" returns a user configuration
    - "buildSpecialArgs" returns a set with attributes that can be used by "specialArgs" and "extraSpecialArgs"
      - It requires a host and a list of users
      - It returns "user", "userDev", "users", and ""host"
        - Note: "userDev" is defined as the first user of the given list of users
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
          startVersion = "";
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

    # Args Builder
    buildSpecialArgs = { users ? [ default.user ], host ? default.host }: (
      let
        userDev = (builtins.head users);
        group = (buildGroup userDev users host);
      in {
        # Single user
        user = group.userDev;
        # Host
        userDev = group.userDev;
        users = group.users;
        host = group.host;
      }
    );

  }
)