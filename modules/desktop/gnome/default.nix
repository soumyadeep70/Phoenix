{ config, lib, ... }:

let
  cfg = config.phoenix.desktop.gnome;
in
{
  options.phoenix.desktop.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gnome Desktop Environment";
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}
