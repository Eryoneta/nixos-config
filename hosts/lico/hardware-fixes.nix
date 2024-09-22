{ pkgs, ... }@args: with args.config-utils; {
  config = {

    # Delays Grub to load the display
    # That bug only affects slow computers (Race condition)
    # https://askubuntu.com/questions/182248/why-is-grub-menu-not-shown-when-starting-my-computer
    boot.loader.grub.extraInstallCommands = ''
      TEMP_FILE="/boot/grub/grubTEMP.tmp"
      GRUB_FILE="/boot/grub/grub.cfg"
      ${pkgs.coreutils}/bin/printf "# Hardware-fix: Delays Grub to load the display\nvideoinfo\nvideoinfo\n\n" | ${pkgs.coreutils}/bin/cat - $GRUB_FILE > $TEMP_FILE && ${pkgs.coreutils}/bin/mv $TEMP_FILE $GRUB_FILE
    '';

    # Dead touchpad
    #services.libinput.enable = false;
    
  };
}
