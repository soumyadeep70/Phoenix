{ config, lib, ... }:

let
  cfg = config.phoenix.desktop.gnome.profile.development;
in
{
  options.phoenix.desktop.gnome.profile.development = {
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

  config = lib.mkIf cfg.enable {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}
