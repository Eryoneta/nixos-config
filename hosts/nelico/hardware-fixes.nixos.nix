{ ... }@args: with args.config-utils; { # (NixOS Module)
  config = {

    # Enable SYSRQ for REISUB
    boot.kernel.sysctl."kernel.sysrq" = 1;
    # Note: KWin might freeze into a loop when dragging a window. Rare, but VERY annoying!

  };
}
