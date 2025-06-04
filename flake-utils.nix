flakePath: (
  let

    # Imports
    setup = (builtins.import ./config-utils/setup-module/setup.nix);
    user-host-scheme = ((builtins.import ./config-utils/user-host-scheme.nix) flakePath);
    config-domain = ((builtins.import ./config-utils/public-private-domains.nix) flakePath);
    config-utils = (builtins.import ./config-utils/config-utils.nix);

  in {
    buildHost = user-host-scheme.buildHost;
    buildUser = user-host-scheme.buildUser;
    buildConfiguration = { inputs, user ? null, users ? null, host, auto-upgrade-pkgs, package-bundle }: (
      let

        # Utilities
        lib = inputs.nixpkgs.lib;
        mapDir = (builtins.import ./config-utils/nix-utils/mapDir.nix lib).mapDir;

        # User-Host Scheme
        allUsers = (if (users == null) then [ user ] else users);
        userDev = (builtins.head allUsers);
        userHostArgs = (user-host-scheme.buildSpecialArgs {
          inherit host;
          users = allUsers;
        });

        # Configuration-Domains
        configDomainArgs = (config-domain.buildSpecialArgs {
          configPath = if (userDev.configDevFolder != "") then userDev.configDevFolder else userDev.configFolder;
          # Note: Allows development in 'develop' branch while "AutoUpgrade" updates 'main' branch
          #   But dotfiles changes (caused by installed programs) should always happen in 'develop' (It's convenient!)
          #   Important: Only absolute paths notices the dev folder
          directories = {
            configurations = "/configurations";
            dotfiles = "/dotfiles";
            programs = "/programs";
            resources = "/resources";
            secrets = "/secrets";
          };
        });

        # Package-Bundle
        pkgs-bundle = (package-bundle host.system.architecture); # (Requires architecture)

        # NixOS-Modules Directory
        nixos-modules = (mapDir ./config-utils/nixos-modules);

        # Configuration-Utilities
        configUtilsArgs = (config-utils.build {
          nixpkgs-lib = inputs.nixpkgs.lib;
          home-manager-pkgs = inputs.nixpkgs.legacyPackages."${host.system.architecture}";
          home-manager-lib = inputs.home-manager.lib;
        });

        # SpecialArgs
        commonSpecialArgs = {
          inherit inputs; # Inputs
          inherit pkgs-bundle; # Package-Bundle
          inherit (configDomainArgs) config-domain; # Configuration-Domains
        };
        setupSpecialArgs = {
          inherit (configUtilsArgs) config-utils; # Configuration-Utilities
        };
        nixosSpecialArgs = (commonSpecialArgs // {
          inherit (userHostArgs) userDev users host; # User-Host-Scheme
          inherit nixos-modules; # NixOS-Modules Directory
          inherit auto-upgrade-pkgs; # Auto-Upgrade
        });
        homeManagerSpecialArgs = (commonSpecialArgs);
        # Note: Unfortunadely, Home-Manager Module is used to load all users, as oposed to Home-Manager Standalone
        #   That means, no single "user" argument
        #   But Setup loads every user separately. So it can be used instead
        setupNixosSpecialArgs = (nixosSpecialArgs // setupSpecialArgs // {
          user = userHostArgs.userDev;
        });
        setupHomeSpecialArgs = username: (nixosSpecialArgs // setupSpecialArgs // {
          user = userHostArgs.users.${username}; # User-Host-Scheme
        });

      in {

        # NixOS Configuration
        nixosSystemConfig = (inputs.nixpkgs.lib.nixosSystem {
          system = host.system.architecture;
          pkgs = pkgs-bundle.system; # Replace "pkgs" with a custom one
          # Note: Not exactly necessary. It's here just to make sure "pkgs-bundle.system" and "pkgs" are the same
          modules = [

            # Setup Configuration
            (setup.setupSystem {
              inherit lib;
              modules = [
                ./import-all.nix # Imports all Setup modules
                { # (Setup Module)
                  config = {
                    includeTags = [ "${host.hostname}" "root" ] ++ ( # Includes host, root, and user modules
                      builtins.map (user: user.username) allUsers
                    );
                  };
                }
              ];
              specialArgs = setupNixosSpecialArgs;
            }).nixosModules.setup # Loads all nixos modules from setup

            { # (NixOS-Module)
              config = {
                nixpkgs.config.allowUnfree = true; # Allows unfree packages
              };
            }

            # Home-Manager-Module Configuration
            inputs.home-manager.nixosModules.home-manager # Loads Home-Manager options
            { # (NixOS-Module)
              config = {
                home-manager = {
                  useGlobalPkgs = false; # Ignore system nixpkgs configuration. Every one is configured separately
                  useUserPackages = true; # Save user packages in "/etc/profiles/per-user/$USERNAME" if it's already present in the system ("/etc/profiles/")
                  users = (lib.pipe allUsers [ # Loads all users configurations

                    # Prepare list to be converted to set
                    (x: builtins.map (user: {
                      name = user.username;
                      value = (setup.setupSystem { # Setup Configuration
                        inherit lib;
                        modules = [
                          ./import-all.nix # Imports all Setup modules
                          { # (Setup Module)
                            config = {
                              includeTags = [ "${user.username}" ]; # Includes user modules
                            };
                          }
                        ];
                        specialArgs = (setupHomeSpecialArgs user.username);
                      }).homeManagerModules.setup; # Loads all home modules from setup
                    }) x)

                    # Convert list of users to attrs of users
                    (x: builtins.listToAttrs x)

                  ]);
                  sharedModules = [
                    inputs.plasma-manager.homeManagerModules.plasma-manager # Loads Plasma-Manager options
                    inputs.stylix.homeManagerModules.stylix # Loads Stylix options
                    inputs.agenix.homeManagerModules.default # Loads Agenix options
                  ];
                  extraSpecialArgs = homeManagerSpecialArgs;
                };
              };
            }
            { # (NixOS-Module)
              config = {
                home-manager.extraSpecialArgs = {
                  pkgs = pkgs-bundle.stable; # Replace "pkgs" with a custom one
                  # Note: This allows all home-manager modules to use a different package from the system
                  #   Kernel and KDE Plasma are defined by NixOS. Nearly all apps are defined by Home-Manager
                };
              };
            }
            { # (NixOS-Module)
              config = {
                environment.systemPackages = with pkgs-bundle.stable; [
                  home-manager # Home-Manager: Manages standalone home configurations
                ];
              };
            }

            inputs.stylix.nixosModules.stylix # Loads Stylix options

            # Agenix Configuration
            inputs.agenix.nixosModules.default # Loads Agenix options
            { # (NixOS-Module)
              config = {
                environment.systemPackages = [
                  inputs.agenix.packages.${host.system.architecture}.default # Agenix CLI
                ];
              };
            }

          ];
          specialArgs = nixosSpecialArgs;
        });

        # Home-Manager-Standalone Configuration
        homeManagerConfig = (inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs-stable.legacyPackages.${host.system.architecture};
          modules = [

            # Setup Configuration
            (setup.setupSystem {
              inherit lib;
              modules = [
                ./import-all.nix # Imports all Setup modules
                { # (Setup Module)
                  config = {
                    includeTags = [ "${user.username}" ]; # Includes user modules
                  };
                }
              ];
              specialArgs = (setupHomeSpecialArgs user.username);
            }).homeManagerModules.setup # Loads all home modules from setup

            inputs.plasma-manager.homeManagerModules.plasma-manager # Loads Plasma-Manager options
            inputs.stylix.homeManagerModules.stylix # Loads Stylix options
            inputs.agenix.homeManagerModules.default # Loads Agenix options

          ];
          extraSpecialArgs = homeManagerSpecialArgs;
        });

      }
    );
  }
)