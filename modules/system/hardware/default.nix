{ config, lib, ... }:

let
  cfg = config.phoenix.system.hardware;
in
{
  options.phoenix.system.hardware = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable software support for specific hardwares";
      example = true;
    };
    enableBluetooth = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable bluetooth";
      example = false;
    };
    enableVideoDrivers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable bluetooth";
      example = false;
    };
  };

  imports = [
    ./intel.nix
  ];

  config = lib.mkIf cfg.enable {
    hardware.enableAllFirmware = true;
    services.fwupd.enable = true;

    hardware.graphics = lib.mkIf cfg.enableVideoDrivers (
      lib.warnIfNot (cfg.intel.iGPU.enable || cfg.intel.dGPU.enable)
        "Please define your GPU info using specific vendor modules. See phoenix.system.hardware.intel for more details."
        {
          enable = true;
          enable32Bit = true;
        }
    );

    hardware.bluetooth = lib.mkIf cfg.enableBluetooth {
      enable = true;
      powerOnBoot = false;
    };
  };
}
