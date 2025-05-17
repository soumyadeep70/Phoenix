{
  config,
  lib,
  ...
}:
let
  cfg = config.phoenix.system.desktop.hyprland;
in
{
  options.phoenix.system.desktop.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hyprland (Window Manager and Compositor)";
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
