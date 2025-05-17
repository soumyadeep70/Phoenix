{
  config,
  lib,
  ...
}:
let
  cfg = config.phoenix.system.hardware;
in
{
  options.phoenix.system.hardware = {
    enableBluetooth = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable bluetooth";
      example = false;
    };
  };

  config = {
    hardware.enableAllFirmware = true;
    services.fwupd.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.bluetooth = lib.mkIf cfg.enableBluetooth {
      enable = true;
      powerOnBoot = false;
    };
  };
}
