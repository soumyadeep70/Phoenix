{ config, lib, ... }:

let
  cfg = config.phoenix.desktop.gnome;
in
{
  options.phoenix.desktop.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GNOME";
      example = true;
    };
    profile = lib.mkOption {
      type = lib.types.submodule {
        options = {
          development = lib.mkOption {
            type = lib.types.submodule {
              enable = lib.mkEnableOption "GNOME Development profile";
              user = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Specify the user for development profile";
                example = "bob";
              };
            };
            description = ''
              This is the development profile for GNOME, which provides
              some applications and utilities useful for software development.
            '';
          };
          pentesting = {

          };
          gaming = {

          };
        };
      };
      default = "standard";
      description = "Choose profile for GNOME";
      example = "gaming";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}
