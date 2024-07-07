{ config, pkgs, host, ... }: {
  config = {

    # Atrasa Grub para que seu video carregue
    boot.loader.grub.extraInstallCommands = ''
      TEMP_FILE="/boot/grub/grubTEMP.tmp"
      GRUB_FILE="/boot/grub/grub.cfg"
      ${pkgs.coreutils}/bin/echo "videoinfo" | ${pkgs.coreutils}/bin/cat - $GRUB_FILE > $TEMP_FILE && ${pkgs.coreutils}/bin/mv $TEMP_FILE $GRUB_FILE
    '';

    # Dead touchpad
    #services.libinput.enable = false;
  };
}