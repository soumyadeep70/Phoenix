{
  config,
  lib,
  ...
}:
let
  cfg = config.phoenix.system.services;
in
{
  options.phoenix.system.services = {
    enablePowerManagement = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable power management to optimize temperature and power usage";
      example = false;
    };
  };

  config = (
    lib.mkMerge [
      (lib.mkIf cfg.enablePowerManagement {
        services.upower = {
          enable = true;
          ignoreLid = true;
        };
        services.thermald = {
          enable = true;
          ignoreCpuidCheck = true;
        };
      })
    ]
  );
}
