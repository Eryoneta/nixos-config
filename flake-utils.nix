flakePath: (
  let

    # Imports
    setup = (builtins.import ./config-utils/setup-module/setup.nix);
    user-host-scheme = ((builtins.import ./config-utils/user-host-scheme.nix) flakePath);
    config-domain = ((builtins.import ./config-utils/public-private-domains.nix) flakePath);
    config-utils = (builtins.import ./config-utils/config-utils.nix);
    mapDir = (builtins.import ./config-utils/nix-utils/mapDir.nix);

  in {
    buildHost = user-host-scheme.buildHost;
    buildUser = user-host-scheme.buildUser;
    buildConfiguration = { inputs, user ? null, users ? null, host, auto-upgrade-pkgs, package-bundle }: (
      let
        allUsers = (if (users == null) then [ user ] else users);
        userDev = (builtins.head allUsers);
        userHostArgs = (user-host-scheme.buildSpecialArgs {
          inherit host;
          users = allUsers;
        });
        lib = inputs.nixpkgs.lib;
        configDomainArgs = (config-domain.buildSpecialArgs { # Config Domain
          configPath = if (userDev.configDevFolder != "") then userDev.configDevFolder else userDev.configFolder;
          # Note: Allows development in 'develop' branch while "AutoUpgrade" updates 'main' branch
          #   But dotfiles changes (caused by installed programs) should always happen in 'develop' (It's convenient!)
          #   Important: Only absolute paths notices the dev folder
          directories = {
            dotfiles = "/dotfiles";
            programs = "/programs";
            resources = "/resources";
            secrets = "/secrets";
          };
        });
        pkgs-bundle = (package-bundle host.system.architecture); # Packages (Requires architecture)
        nixos-modules = (mapDir ./config-utils/nixos-modules); # NixOS-Modules Directory
        configUtilsArgs = (config-utils.build {
          nixpkgs-lib = inputs.nixpkgs.lib;
          home-manager-pkgs = inputs.nixpkgs.legacyPackages."${host.system.architecture}";
          home-manager-lib = inputs.home-manager.lib;
        });
      in {

        # NixOS Configuration
        nixosSystemConfig = (inputs.nixpkgs.lib.nixosSystem {
          system = host.system.architecture;
          modules = [

            # Setup Configuration
            (setup.setupSystem {
              inherit lib;
              modules = [
                "${flakePath}/hosts/${host.hostname}/configuration.setup.nix" # Loads host configuration
              ];
              specialArgs = {
                inherit pkgs-bundle; # Package Bundle
                inherit (configUtilsArgs) config-utils; # Config-Utils
                inherit (userHostArgs) userDev users host; # User-Host-Scheme
                inherit (configDomainArgs) config-domain; # Config-Domain
                inherit nixos-modules; # NixOS-Modules Directory
                inherit auto-upgrade-pkgs; # Auto-Upgrade
              };
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
                  users = (inputs.nixpkgs.lib.pipe allUsers [ # Loads all users configurations

                    # Prepare list to be converted to set
                    (x: builtins.map (user: {
                      name = user.username;
                      value = (setup.setupSystem { # Setup Configuration
                        inherit lib;
                        modules = [
                          "${flakePath}/users/${user.username}.setup.nix"  # Loads user configuration
                        ];
                        specialArgs = {
                          inherit pkgs-bundle; # Package Bundle
                          inherit (configUtilsArgs) config-utils; # Config-Utils
                          inherit (userHostArgs) user; # User-Host-Scheme
                          inherit (configDomainArgs) config-domain; # Config-Domain
                          inherit nixos-modules; # NixOS-Modules Directory
                        };
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
                  extraSpecialArgs = {};
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
                environment.systemPackages = [
                  pkgs-bundle.stable.home-manager # Home-Manager: Manages standalone home configurations
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
          specialArgs = {};
        });

        # Home-Manager-Standalone Configuration
        homeManagerConfig = (inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs-stable.legacyPackages.${host.system.architecture};
          modules = [

            # Setup Configuration
            (setup.setupSystem {
              inherit lib;
              modules = [
                "${flakePath}/users/${user.username}.setup.nix"  # Loads user configuration
              ];
              specialArgs = {
                inherit pkgs-bundle; # Package Bundle
                inherit (configUtilsArgs) config-utils; # Config-Utils
                inherit (userHostArgs) user; # User-Host-Scheme
                inherit (configDomainArgs) config-domain; # Config-Domain
                inherit nixos-modules; # NixOS-Modules Directory
              };
            }).homeManagerModules.setup # Loads all home modules from setup

            inputs.plasma-manager.homeManagerModules.plasma-manager # Loads Plasma-Manager options
            inputs.stylix.homeManagerModules.stylix # Loads Stylix options
            inputs.agenix.homeManagerModules.default # Loads Agenix options

          ];
          extraSpecialArgs = {};
        });

      }
    );
  }
)