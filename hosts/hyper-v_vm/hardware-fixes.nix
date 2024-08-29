{ config, pkgs, host, ... }: {
  config = {

    # Hyper-V não funciona com KDE Plasma. O gráfico deve ser básico
    boot.kernelParams = ["nomodeset"];

  };
}
