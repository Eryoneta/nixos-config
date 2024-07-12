# NixOS Configuration

Based on Linux, NixOS is quite a unique distro. It allows for a almost complete control over the entire system with the use of a single configuration file(That get a bit too big, so you inevitably end up breaking it into parts, of course) and that brings a unique possibility: Recreating an entire OS with only a configuration file(And Internet access).

My NixOS is my first take on Linux. Not a conventional way to get familiar with the ecosystem, but I hope it pays well in the end. An entire OS, configured __exactly__ how I want it to!

### Some Achievements
- Flakes: A declarative way of defining the system's inputs and outputs. It allows my system to have many different packages as inputs and many different hosts as outputs. Also, it pins the exact commit for each input, allowing for a precise recreation of the system, which is nice.
- _Home Manager_ both as standalone and as a NixOS module: It allows for quick edits on dotfiles (`home-manager switch`) without recreating the system, but it also allows the newly recreated system (`sudo nixos-rebuild switch`) to manage the home folder.
- Multiple hosts and users, and a easy way to pair them. In theory.
- Multiple inputs, allowing for different packages: Some packages can be the latest version(_unstable_), others can be unchanging until the system upgrades(_stable_).
- AutoUpgrade! Total control when and how the system upgrades!
  - Some packages can be automatically updated, others can be only when required (Manual update).
- Might document it all when I finish tinkering. The entire OS. Every option.

### Some Details
- My dotfiles, secrets, and some files are outside this repo. Privacy and all that.
- Some stuffs might not work, idk. I'm learning.
