{ config, lib, ... }:

{
  options.system.hardware.gpu.specs = {
    intel = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            codename = lib.mkOption {
              type = lib.types.strMatching "^[A-F]+$";
              description = "The GPU codename";
              example = "KBL";
            };
            pciDeviceId = lib.mkOption {
              type = lib.types.strMatching "^[0-9a-fA-F]{4}$";
              description = "
                PCI Device ID of the GPU (found in /sys/class/drm/card*/device/device),
                strip out the hexadecimal prefix `0x`.
              ";
              example = "5916";
            };
            forceDriver = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  "i915"
                  "xe"
                ]
              );
              default = null;
              description = "Force probe specific kernel driver (`i915` or `xe`)";
              example = "i915";
            };
          };
        }
      );
    };
    # TODO: define options for amd gpus
    amd = {

    };
    # TODO: define options for nvidia gpus
    nvidia = {

    };
  };
}
