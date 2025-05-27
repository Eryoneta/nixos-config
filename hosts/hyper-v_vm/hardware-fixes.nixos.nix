{ ... }@args: with args.config-utils; { # (NixOS Module)
  config = {

    # "Hyper-V" does NOT like "KDE Plasma". Only "NoModeSet" works...
    boot.kernelParams = ["nomodeset"];

  };
}
