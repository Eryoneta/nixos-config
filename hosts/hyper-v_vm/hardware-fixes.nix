{ tools, ... }: with tools; {
  config = {

    # "Hyper-V" does NOT like "KDE Plasma". Only "NoModeSet" works...
    boot.kernelParams = ["nomodeset"];

  };
}
