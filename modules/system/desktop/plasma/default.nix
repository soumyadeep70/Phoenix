{
  config,
  lib,
  ...
}:
let
  cfg = config.phoenix.system.desktop.plasma;
in
{
  options.phoenix.system.desktop.plasma = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable KDE Plasma (Desktop Environment)";
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
