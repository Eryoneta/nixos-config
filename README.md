[![NixOS Stable](https://img.shields.io/badge/NixOS-25.05-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)
# My NixOS Configuration

Based on Linux, NixOS is quite a unique distro! It allows for a almost complete control over the entire system with the use of a single configuration file (That get a bit too big, so you inevitably end up breaking it into parts, of course) and that brings a unique possibility: Recreating an entire OS with only a configuration file (And Internet access).

My NixOS configuration is my first take on Linux. Not a conventional way to get familiar with the ecosystem, but the idea it proposes was way too tempting! An entire OS, <s>in the palm of my</s> configured __exactly__ how I want it to!

### Overview
- _Flakes_: A way to declare the system's inputs and outputs. It allows my system to have many different repositories as inputs and many different hosts as outputs. Also, it pins the exact commit for each input, allowing for a precise recreation of the system, which is nice.
- _Home-Manager_, both as standalone and as a NixOS module: It allows for quick edits on dotfiles (`home-manager switch`) without recreating the system, but it also allows the newly recreated system (`sudo nixos-rebuild switch`) to manage my home folder.
  - _Plasma-Manager_: A module which allows to declare _KDE Plasma_ configuration.
  - _Stylix_: Declares colors, themes, and wallpapers for a bunch of programs. It's perfect to theme the environment without unholy hours of work.
- _Agenix_: Stores secrets as encripted files, and decripts them at runtime. Nor _Git_ or _Nix_ knows the content, only _NixOS_ does, when its running.

### Highlights
- My `flake.nix` is meant to be easy to read and edit. However, a lot of the necessary logic is hidden within `flake-utils.nix`.
- My entire configuration is divided between `./public-config/` and `./private-config/` (Which is a _Git_ submodule. Privacy and all that).
  - The directory `./programs/` inside contains all the programs I use. It's giant and messy. It's Perfect.
- EVERYTHING is imported by `import-all.nix`.
- `./config-utils/nixos-modules/` contains useful functionalities. These can be imported and used by a _NixOS_ configuration.
- `./config-utils/nix-utils/` contains useful _Nix_ functions.
- `./config-utils/config-utils.nix` contains all the _Nix_ functions my configuration uses, including from `nix-utils/`.
- `./config-utils/setup-module/` contains my own module system, used by this configuration.
  - All _Nix_ files here are _Setup_ modules.
  - More can be read at [Setup-Module](./config-utils/setup-module/README.md).
- [NX-Command](./public-config/programs/shells/zsh+nx-command.nix) is a ZSH function, used to easily run necessary commands to maintain a _NixOS_ configuration.
- [AutoUpgrade](./public-config/configurations/system-features+auto-upgrade.nix) is also provided by a _NixOS_ module, but here it is improved with a few extra functionalities.
