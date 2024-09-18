{ ... }@args: with args.config-utils; {
  config = {

    # "Hyper-V" does NOT like "KDE Plasma". Only "NoModeSet" works...
    boot.kernelParams = ["nomodeset"];

  };
}
