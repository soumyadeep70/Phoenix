{
  config,
  lib,
  phoenix-lib,
  ...
}:
let
  cfg = config.phoenix.system.desktop.plasma;

  styles = builtins.map (
    file: lib.removeSuffix ".nix" (lib.removePrefix ((builtins.toString ./styles) + "/") file)
  ) (phoenix-lib.files.getFiles ./styles);
in
{
  options.phoenix.system.desktop.plasma = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable KDE Plasma (Desktop Environment)";
      example = true;
    };
    style = lib.mkOption {
      type = lib.types.enum styles;
      default = "modern";
      description = "Select which style to apply";
      example = builtins.tail styles;
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
