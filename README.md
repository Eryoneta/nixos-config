[![NixOS Stable](https://img.shields.io/badge/NixOS-25.05-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)
# My NixOS Configuration

Based on Linux, NixOS is quite a unique distro! It allows for a almost complete control over the entire system with the use of a single configuration file (That get a bit too big, so you inevitably end up breaking it into parts, of course) and that brings a unique possibility: Recreating an entire OS with only a configuration file (And Internet access).

My NixOS configuration is my first take on Linux. Not a conventional way to get familiar with the ecosystem, but the idea it proposes was way too tempting! An entire OS, <s>in the palm of my</s> configured __exactly__ how I want it to!

### Highlights
- _Flakes_: A way to declare the system's inputs and outputs. It allows my system to have many different repositories as inputs and many different hosts as outputs. Also, it pins the exact commit for each input, allowing for a precise recreation of the system, which is nice.
- _Home-Manager_, both as standalone and as a NixOS module: It allows for quick edits on dotfiles (`home-manager switch`) without recreating the system, but it also allows the newly recreated system (`sudo nixos-rebuild switch`) to manage my home folder.
  - _Plasma-Manager_: A module which allows to declare many of the options of _KDE Plasma_.
  - _Stylix_: Declares colors, themes, and wallpapers for a bunch of programs. Its perfect to theme the environment without unholy hours of work.
- _Agenix_: Stores secrets as encripted files, and decripts them at runtime. Nor _Git_ or _Nix_ knows the content, only _NixOS_ does, when its running.

### Special Stuff
- My flake might be clean, but a lot of the mess is hidden within `configurationBuilder.nix`.
- My entire configuration is basically divided between `./public-config` and `./private-config`, which is a _Git_ submodule. Privacy and all that.
  - The directory `./programs` inside contains all programs which require configuration. Its giant and messy. Its Perfect.
    - They are all automatically imported based on the file names.
- Both `./hosts` and `./users` contains a `./default` configuration, and specific configuration for each one.
- Anything inside `./modules` is made to be portable.
  - `./modules/flake-modules` contains a lot of utilities that abstracts contents of `flake.nix`.
    - Starting from `nixos-system.nix`, they can be strung together to "modify" a basic configuration into a more complete one.
    - For example, `home-manager-module.nix` can be used by `nixos-system.nix` to generate a _NixOS_ with _Home-Manager_ module installed.
    - There is a bunch more.
  - `./modules/nix-modules` are "simple" nix functions. Useful utilities and stuff.
  - `./modules/nixos-modules` can be imported by a configuration. They add new options and functionalities.
 - System upgrades uses this `nixos-config`(`main`) repository, but all my development happens at `nixos-config-dev`(`develop`), which is a _Git_ worktree.
   - Only working builds are merged into `main`. This avoids a surprise upgrade that uses an half-done configuration.
