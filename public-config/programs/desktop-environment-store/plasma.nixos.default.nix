{ lib, config, host, ... }@args: with args.config-utils; {
  config = (
    with config.home-manager.users.${host.user.username};
    with profile.programs.plasma; (lib.mkIf (options.enabled) {

      # Plasma: A "Desktop Environment" focused on customization
      services.desktopManager.plasma6 = {
        enable = options.enabled;
      };

      # System programs
      environment.systemPackages = with options.packageChannel; [
        wayland-utils # Wayland Utils: Used by Plasma to display information about Wayland
        aha # Ansi HTML Adapter: Used by Plasma to format information
        pciutils # PCI Utilities: Used by Plasma to display information about PCI
        kdePackages.qtimageformats # QTImageFormats: Tools for generating thumbnails (Includes .webp support)
      ];

      # FWUpd: Used by Plasma to update firmwares
      services.fwupd = {
        enable = (utils.mkDefault) options.enabled;
        package = (utils.mkDefault) (options.packageChannel).fwupd;
      };

    })
  );
}
