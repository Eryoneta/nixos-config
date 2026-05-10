{ config, pkgs-bundle, userDev, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # MindSort: My own mindmap program
  config.modules."mindsort" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
    attr.mkOutOfStoreSymlink = config.modules."configuration".attr.mkOutOfStoreSymlink;
    attr.isDomainLoaded = config.modules."configuration".attr.isDomainLoaded;
    attr.mkFilePath = config.modules."configuration".attr.mkFilePath;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # mindsort = pkgs.stdenv.mkDerivation {
        #   name = "mindsort";
        #   version = "1.3.1";
        #   src = args.pkgs-bundle.mindsort;
        #   buildInputs = with pkgs; [
        #     jdk
        #     jre8
        #   ];
        #   buildPhase = ''
        #     javac
        #   '';
        #   installPhase = ''
        #     mkdir -p $out/bin
        #     cp $src/mindsort.jar $out/bin
        #   '';
        # };
        # TODO: (MindSort) Compile from source

        # Dependecies
        config.home.packages = with attr.packageChannel; [
          # jre8 # JRE8: Java Runtime Environment v8
          # TODO: (MindSort) Set Java version. For now Java v17 is good
        ];

        config.xdg = (
          let
            mind-mimeType = "application/mind";
            mind-icon-name = "x-mind-icon";
            mind-icon-size = "48x48";
          in {

            # Desktop entry
            desktopEntries."mindsort" = {
              name = "MindSort";
              genericName = "Mind Map Editor";
              icon = (attr.mkFilePath {
                public-resource = "mindsort/Icon.png";
                default-resource = "";
              });
              exec = (
                let
                  exec = (attr.mkFilePath {
                    public-resource = "mindsort/MindSort-Linux_Patched.jar";
                    default-resource = "";
                  });
                in ''
                  java -jar "${exec}" %U
                ''
              );
              terminal = false;
              categories = [ "Utility" ];
              mimeType = [ mind-mimeType ];
            };

            # Icon
            dataFile."icons/hicolor/${mind-icon-size}/mimetypes/${mind-icon-name}.png" = (attr.mkSymlink {
              public-resource = "mindsort/Icon.png";
            });

            # Mime type: "application/mind"
            dataFile."mime/packages/x-mind.xml" = {
              text = ''
                <?xml version="1.0" encoding="UTF-8"?>
                <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
                  <mime-type type="${mind-mimeType}">
                    <comment>MindSort file</comment>
                    <glob pattern="*.mind"/>
                    <icon name="${mind-icon-name}" />
                  </mime-type>
                </mime-info>
              '';
            };

            # Default app
            mimeApps.defaultApplications = {
              # Mind map
              "${mind-mimeType}" = (utils.mkDefault) [ "mindsort.desktop" ];
            };

            # Dotfiles
            configFile."mindsort" = (
              # Only the developer should be able to modify the file
              (if (config.home.username == userDev.username) then attr.mkOutOfStoreSymlink else attr.mkSymlink) {
                public-dotfile = "mindsort/.config/mindsort";
              }
            );

          }
        );

      };
    };
  };

}
