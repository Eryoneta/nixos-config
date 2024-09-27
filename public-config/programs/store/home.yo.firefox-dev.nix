{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Firefox Developer Edition: Browser
    # The profile is shared with regular "Firefox" (Convenient!)
    home.packages = with pkgs-bundle.unstable; [ firefox-devedition ];

    # Can be used alonside regular "Firefox"
    # But! There is potential for a conflict between the two!
    #   Here, "firefox" is using "pkgs-bundle.stable"
    #   And "firefox-devedition" is using "pkgs-bundle.unstable"
    #   Pray that the two packages are "far away" from eachother(Different versions)
    #   If not, there is a conflict and the rebuild fails
    # TODO: Fix? How?

  };
}
