{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.phoenix.system.hardware.gpu.intel;

  # Date: 13/05/25
  # https://github.com/intel/vpl-gpu-rt#how-to-use
  vpl-gpu-rt-support = [
    "TGL"
    "RKL"
    "ADL"
    "RPL"
    "DG1"
    "DG2"
    "MTL"
    "ARL"
    "LNL"
    "BMG"
  ];
  # https://github.com/Intel-Media-SDK/MediaSDK#media-sdk-support-matrix
  media-sdk-support = [
    "BDW"
    "SKL"
    "BXT"
    "APL"
    "KBL"
    "CFL"
    "WHL"
    "CML"
    "AML"
    "ICL"
    "JSL"
    "EHL"
    "TGL"
    "DG1"
    "SG1"
    "RKL"
  ];
  # https://github.com/intel/media-driver?tab=readme-ov-file#supported-platforms
  media-driver-support = [
    "BDW"
    "SKL"
    "BXT"
    "APL"
    "GLK"
    "KBL"
    "CFL"
    "WHL"
    "CML"
    "AML"
    "ICL"
    "JSL"
    "EHL"
    "TGL"
    "RKL"
    "ADL"
    "RPL"
    "DG1"
    "SG1"
    "DG2"
    "MTL"
    "ARL"
    "LNL"
    "BMG"
  ];
  # https://github.com/intel/compute-runtime#supported-platforms
  compute-runtime-support = [
    "TGL"
    "RKL"
    "ADL"
    "RPL"
    "MTL"
    "ARL"
    "LNL"
    "DG1"
    "DG2"
    "BMG"
  ];
  # https://github.com/intel/compute-runtime/blob/master/LEGACY_PLATFORMS.md#supported-legacy-platforms
  compute-runtime-legacy1-support = [
    "BDW"
    "SKL"
    "KBL"
    "CFL"
    "APL"
    "GLK"
    "ICL"
    "EHL"
  ];

  extraDriversFor =
    specs:
    [ ]
    ++ lib.optionals (builtins.elem specs.codename vpl-gpu-rt-support) [
      pkgs.libvpl
      pkgs.vpl-gpu-rt
    ]
    ++ lib.optionals (builtins.elem specs.codename media-sdk-support) [
      pkgs.libvpl
      pkgs.intel-media-sdk
    ]
    ++ lib.optionals (builtins.elem specs.codename compute-runtime-support) [
      pkgs.intel-compute-runtime
    ]
    ++ lib.optionals (builtins.elem specs.codename compute-runtime-legacy1-support) [
      pkgs.intel-compute-runtime-legacy1
    ]
    ++ (
      if (builtins.elem specs.codename media-driver-support) then
        [
          pkgs.libva
          pkgs.intel-media-driver
        ]
      else
        [
          pkgs.libva
          pkgs.intel-vaapi-driver
        ]
    );

  extraDrivers32For =
    specs:
    [ ]
    ++ (
      if (builtins.elem specs.codename media-driver-support) then
        [ pkgs.driversi686Linux.intel-media-driver ]
      else
        [ pkgs.driversi686Linux.intel-vaapi-driver ]
    );

  extraKernelParamsFor =
    specs:
    [ ]
    ++ lib.optionals (specs.forceDriver == "i915") [
      "i915.force_probe=${specs.pciDeviceId}"
      "xe.force_probe=!${specs.pciDeviceId}"
    ]
    ++ lib.optionals (specs.forceDriver == "xe") [
      "i915.force_probe=!${specs.pciDeviceId}"
      "xe.force_probe=${specs.pciDeviceId}"
    ];
in
{
  options.phoenix.system.hardware.gpu = {
    intel = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            codename = lib.mkOption {
              type = lib.types.strMatching "^[A-Z0-9]+$";
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
      default = [ ];
      description = "Specify the intel GPUs available";
    };
  };

  config = {
    hardware.graphics.extraPackages = lib.concatMap (specs: extraDriversFor specs) cfg;
    hardware.graphics.extraPackages32 = lib.concatMap (specs: extraDrivers32For specs) cfg;
    boot.kernelParams = lib.concatMap (specs: extraKernelParamsFor specs) cfg;
  };
}
