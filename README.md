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

### Structure
- My [`flake.nix`](./flake.nix) is meant to be easy to read and edit. However, a lot of the necessary logic is hidden within [`flake-utils.nix`](./flake-utils.nix).
- [`users/`](./users/) and [`hosts/`](./hosts/) have specific configurations for each host and user.
- My entire configuration is divided between [`public-config/`](./public-config/) and [`private-config/`](./private-config/) (Which is a _Git_ submodule. Privacy and all that).
- EVERYTHING is imported by [`import-all.nix`](./import-all.nix).
- [`config-utils/nix-utils/`](./config-utils/nix-utils/) contains useful _Nix_ functions.
- [`config-utils/nixos-modules/`](./config-utils/nixos-modules/) contains useful _NixOS_ modules.
- [`config-utils/setup-module/`](./config-utils/setup-module/) contains my own module system, used by this configuration.
  - All _Nix_ files here are _Setup_ modules.
  - More can be read at [Setup-Module](./config-utils/setup-module/).
  - All the tags I use are defined within [`setups.nix`](./setups.nix).
- [`config-utils/config-utils.nix`](./config-utils/config-utils.nix) contains all the utilities my configuration uses, including from [`nixos-modules/`](./config-utils/nixos-modules/) and [`nix-utils/`](./config-utils/nix-utils/).
  - All _Nix_ files here have it included by default.

### Highlights
- [NX-Command](./public-config/programs/shells/zsh+nx-command.nix): A ZSH function, used to easily run necessary commands to maintain a _NixOS_ configuration.
- [Swapfile, ZRAM, and Hibernation](./public-config/configurations/system-features.nix): Configured for all hosts.
- [NixOS Auto-Upgrade](./public-config/configurations/system-features+auto-upgrade.nix): Is also provided by a _NixOS_ module, but here it's improved with a few extra functionalities.
- [Tiled Menu declaration](./public-config/programs/desktop-environments/plasma-tiledmenu.nix): Provides [Tiled Menu](https://github.com/Zren/plasma-applet-tiledmenu) with the menu fully declared. Very cool.
- [KZones declaration](public-config/programs/desktop-environments/plasma-kwin-kzones.personal.nix): Provides [KZones](https://github.com/gerritdevriese/kzones) with snap zones declared.
- [MPV configuration](./public-config/programs/apps/mpv.nix): Configures [MPV](https://mpv.io/) actions, shortcuts, and more. It's quite big.
- [Firefox for work](./public-config/programs/apps/firefox.nix) and [Firefox-Developer for daily use](./public-config/programs/apps/firefox-devedition.nix): Two different versions of [Firefox](https://www.firefox.com) with A TON of settings.
  - NixOS only allows one version to be used. That's very clear when the whole system crashes, or behaves weirdly.
  - But when it works, it works. Having two "Firefoxes" is neat.
- [GRUB with a theme](./public-config/programs/bootloaders/grub.nix): Declares a custom [GRUB](https://www.gnu.org/software/grub/) theme.
- [Fastfetch configuration](./public-config/programs/apps/fastfetch.nix): Simplifies the configuration of [Fastfetch](https://github.com/fastfetch-cli/fastfetch).
