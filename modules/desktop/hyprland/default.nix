{ config, lib, ... }:

let
  cfg = config.phoenix.desktop.hyprland;
in
{
  options.phoenix.desktop.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable HYPRLAND";
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
}
