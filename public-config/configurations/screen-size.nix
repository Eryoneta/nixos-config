{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Note: This is useful for setting window apps to be an exact desired size relative to screen size

  # Screen size options
  options = {
    hardware.configuration.screenSize = {
      width = (utils.mkIntOption 1366);
      height = (utils.mkIntOption 768);
      horizontalBars = (utils.mkIntListOption []);
      verticalBars = (utils.mkIntListOption []);
      workArea = {
        width = (utils.mkIntOption 1366);
        height = (utils.mkIntOption 768);
      };
    };
  };

  # Screen size work area configuration
  config = {
    hardware.configuration.screenSize.workArea = (with config.hardware.configuration.screenSize; {
      width = (builtins.foldl' (finalWidth: barWidth: (
        finalWidth - barWidth
      )) width horizontalBars);
      height = (builtins.foldl' (finalHeight: barHeight: (
        finalHeight - barHeight
      )) height verticalBars);
    });
  };

}
