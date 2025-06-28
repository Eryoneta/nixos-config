# Setup-Manager

Do you have a lot of _Nix_ files in yout config? It is messy and hard to maintain? Do you use _Home-Manager_ and wish you could just merge all of its configs with _NixOS_ but still keep _Home-Manager_ as a standalone system?

This here thingie is the solution for all that!

(Inspired by [nix-config-modules](https://github.com/chadac/nix-config-modules)).


## First, some context

_NixOS_ is configured by `.nix` files. Each one is a _NixOS_ module.

Inside, many options can be declared and set. And, magically, they are all merged into a single, final output, which is used by _NixOS_ to create a new system.

Notably, _NixOS_ modules do not have options for declaring user stuff. It is for system only (I mean, that's the intention). Here, _Home-Manager_ is used to fill that gap.

The problem? _Home-Manager_ have its own modules, and it allows the user stuff to be declared independently from the system. That's pretty cool! It means it can be used in any other system, as long as _Home-Manager_ is installed. ...But that requires keeping both modules apart from eachother, which is a bit of a pain.

As a example, ZSH can be fully configured by _Home-Manager_, but only _NixOS_ can set it to be the user default shell. It requires two files to be fully declared. Multiply that for a few more other cases, and it can be quite distressing to see the amount of files with similar names.

There should be a way to "merge" a _Home-Manager_ and _NixOS_ module together.

Introducing, _Setup-Manager_!


## Eval the modules!

Within all the functions within `lib`, there is `evalModules`. This beauty takes a set with `modules` and `specialArgs` and creates a module system.

This module system contains no options set, only a empty `config` and `options`. New options can easily be declared and used. One module can import others, and a whole tree of modules can be evaluated into a final output.

This is the magician that allows _NixOS_ and _Home-Manager_ modules to function the way they do.

There is nothing stopping you from creating your own module system.


## Features

- **Modules**:
    - `config.modules.*` lets you declare named modules.
    - It allows the configuration to be divided into many different chunks which can be selectively included into the final configuration.
- **Tags**:
    - `config.modules.*.tags` accepts a list of tags.
    - `config.modules.*.includeTags` lets a module add more tags, if it is included.
    - `config.includeTags` is a list of included tags. Any module with that tag is included into the final configuration.
    - `config.includedModules` lists all the final included modules. It is read-only.
    - This allows a very dinamic way of creating a configuration.
        - Although, I suggest it's best to keep it simple. Too many tags can be quite confusing.
- **Toggles**:
    - `config.modules.*.enable` can disable a module.
    - `config.modules.*.include` can include or exclude a module regardless of its tags.
    - It allows a more fine control.
- **Atributes**:
    - `config.modules.*.attr` lets you declare whatever you want.
        - Useful functions? Important values? Whatever it is, it can be stored in it.
    - It's essencially a `let in`, but for a module, and it can be shared with other modules.
- **Setup**:
    - `config.modules.*.setup` can be either a function with a `{ attr }` argument, or a set.
        - Here, `attr` is loaded with the contents of `config.modules.*.attr`.
    - `config.modules.*.setup.nixos` can be set with a _NixOS_ module.
    - `config.modules.*.setup.home` can be set with a _Home-Manager_ module.
    - `config.modules.*.setup.darwin` can be set with a _Darwin_ module.
        - In theory. I've never tested it.
    - All the modules, at last together.
- The output is `nixosModules.setup`, `homeModules.setup`, and `darwinModules.setup`. These are a valid _NixOS_/_Home-Manager_/_Darwin_ module.

## Example

(With a Flake).

```nix
{
    description = "Setup-Manager example";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    }
    outputs = { ... }@inputs: {
        setup-manager = (builtins.import ./config-utils/setup-manager/setup-manager.nix);
        nixosConfigurations = {
            "MyHost" = (inputs.nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [

                    # Setup-Manager
                    (setup-manager.setupSystem {
                        inherit (inputs.nixpkgs) lib;
                        modules = [
                            { # (Setup-Manager Module)
                                config.includeTags = [ "my-host" ];
                                # Any module with the tag "my-host" is included
                            }
                            ({ config, ... }: { # (Setup-Manager Module)
                                config.modules."my-host" = {
                                    tags = [ "my-host" ];
                                    includeTags = [ "default-host-stuff" ];
                                    # If included, it also includes the tag "default-host-stuff"
                                    attr.usefulFunc = config.modules."default-thingie1".attr.usefulFunc;
                                    # It "imports" the function from another module
                                    setup = { attr }: { # "attr" is used
                                        nixos = {
                                            # ...
                                        };
                                    }
                                };
                            })
                            { # (Setup Module)
                                config.modules."default-thingie1" = {
                                    tags = [ "default-host-stuff" ];
                                    attr.usefulFunc = a: a + "b";
                                    setup = { # "attr" is not used. It exists only to be used by others
                                        nixos = {
                                            # ...
                                        };
                                        home = { # This one is included only within "homeModules.setup"
                                            # ...
                                        };
                                    }
                                };
                            }

                            # Other Setup modules...

                        ];
                        specialArgs = { # This one is for Setup-Manager, not NixOS!
                            inherit inputs;
                        };
                    }).nixosModules.setup # Loads all NixOS modules from setup
                    # This output is a valid NixOS module and can be treated as such

                    # Other NixOS modules...

                ];
            };
        };
    }
}
```
