{ config, host, ... }@args: with args.config-utils; {
  config = with config.home-manager.users.${host.user.username}.profile.programs.plasma; {

    # Plasma: A "Desktop Environment" focused on customization
    services.desktopManager.plasma6 = {
      enable = (utils.mkDefault) options.enabled;
    };

    # System programs
    environment.systemPackages = utils.mkIf (options.enabled) (
      with options.packageChannel; [
        wayland-utils # Wayland Utils: Used by Plasma to display information about Wayland
        aha # Ansi HTML Adapter: Used by Plasma to format information
        pciutils # PCI Utilities: Used by Plasma to display information about PCI
      ]
    );

    # FWUpd: Used by Plasma to update firmwares
    services.fwupd = {
      enable = (utils.mkDefault) options.enabled;
      package = (utils.mkDefault) options.packageChannel.fwupd;
    };

  };
}
