{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.phoenix.profile.gaming;
in
{
  options.phoenix.profile.gaming = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gaming profile";
      example = true;
    };
  };

  config.specialisation.gaming.configuration = lib.mkIf cfg.enable {
    programs = {
      steam.enable = true;
      gamescope.enable = true;
    };
  };
}
