{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.phoenix.system.hardware.intel;
in
{
  options.phoenix.system.hardware.intel = {
    iGPU = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable intel igpu drivers";
        example = true;
      };
      architecture = lib.mkOption {
        type = lib.types.nullOr (lib.types.strMatching "^(Gen[0-9]+|Xe.*)$");
        default = null;
        description = "Define the architecture of intel igpu";
        example = "Gen 9";
      };
      codename = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Define the codename of the intel igpu";
        example = "Kaby Lake";
      };
      pciDeviceId = lib.mkOption {
        type = lib.types.nullOr (lib.types.strMatching "^[0-9a-fA-F]{4}$");
        default = null;
        description = "Define the pci device id of the intel igpu";
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
        description = "Force probe specific kernel driver for this igpu";
        example = "i915";
      };
      enableGuCHuC = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable GuC / HuC firmware loading 
                    (keep it disabled in case of freezing or system instability)";
        example = true;
      };
    };
    dGPU = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable intel dgpu drivers";
        example = true;
      };
      pciDeviceId = lib.mkOption {
        type = lib.types.nullOr (lib.types.strMatching "^[0-9a-fA-F]{4}$");
        default = null;
        description = "Define the pci device id of the intel dgpu";
        example = "E20B";
      };
      forceDriver = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "i915"
            "xe"
          ]
        );
        default = null;
        description = "Force probe specific kernel driver for this dgpu";
        example = "xe";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.iGPU.enable (
      let
        xe = builtins.match "^Xe.*$" cfg.iGPU.architecture;
        gen = builtins.match "^Gen([0-9]+)$" cfg.iGPU.architecture;
        is_arch_xe = xe != null;
        arch_rev = if is_arch_xe then 12 else builtins.fromJSON (builtins.elemAt gen 0);
        is_jasper_lake = cfg.iGPU.codename == "Jasper Lake";
        is_elkhart_lake = cfg.iGPU.codename == "Elkhart Lake";
        is_apollo_lake = cfg.iGPU.codename == "Apollo Lake";
        is_skylake = cfg.iGPU.codename == "Skylake";
      in
      {
        assertions = [
          {
            assertion = builtins.all (info: info != null) (
              with cfg.iGPU;
              [
                architecture
                codename
                pciDeviceId
              ]
            );
            message = "Architecture, Codename and pciDeviceId should be defined for intel igpu";
          }
          {
            assertion = cfg.iGPU.enableGuCHuC -> (arch_rev >= 9);
            message = "GuC / HuC firmware loading is only supported on intel Gen9 graphics and later";
          }
        ];

        hardware.graphics.extraPackages =
          [ pkgs.mesa ]
          ++ lib.optionals (is_arch_xe && !(is_jasper_lake || is_elkhart_lake)) [
            pkgs.libvpl
            pkgs.vpl-gpu-rt
            pkgs.intel-compute-runtime
          ]
          ++ lib.optionals (is_jasper_lake || is_elkhart_lake || (!is_arch_xe && arch_rev >= 8)) [
            pkgs.libvpl
            pkgs.intel-media-sdk
            pkgs.intel-compute-runtime-legacy1
          ]
          ++ lib.optional (is_arch_xe || arch_rev >= 8) pkgs.intel-media-driver
          ++ lib.optional (arch_rev < 8) pkgs.intel-vaapi-driver;

        hardware.graphics.extraPackages32 =
          [ pkgs.driversi686Linux.mesa ]
          ++ lib.optional (is_arch_xe || arch_rev >= 8) pkgs.driversi686Linux.intel-media-driver
          ++ lib.optional (arch_rev < 8) pkgs.driversi686Linux.intel-vaapi-driver;

        boot.kernelParams =
          [ ]
          ++ lib.optionals (cfg.iGPU.forceDriver == "i915") [
            "i915.force_probe=${cfg.iGPU.pciDeviceId}"
            "xe.force_probe=!${cfg.iGPU.pciDeviceId}"
          ]
          ++ lib.optionals (cfg.iGPU.forceDriver == "xe") [
            "i915.force_probe=!${cfg.iGPU.pciDeviceId}"
            "xe.force_probe=${cfg.iGPU.pciDeviceId}"
          ]
          ++ lib.optionals (cfg.iGPU.enableGuCHuC && cfg.iGPU.forceDriver != "xe") [
            "i915.enable_guc=${if (is_skylake || is_apollo_lake) then 2 else 3}"
          ];
      }
    ))
    (lib.mkIf cfg.dGPU.enable {
      assertions = [
        {
          assertion = cfg.dGPU.pciDeviceId != null;
          message = "pciDeviceId should be defined for intel dgpu";
        }
      ];

      hardware.graphics.extraPackages = with pkgs; [
        mesa
        libvpl
        vpl-gpu-rt
        intel-media-driver
        intel-compute-runtime
      ];
      hardware.graphics.extraPackages32 = with pkgs.driversi686Linux; [
        mesa
        intel-media-driver
      ];

      boot.kernelParams =
        [ ]
        ++ lib.optionals (cfg.dGPU.forceDriver == "i915") [
          "i915.force_probe=${cfg.dGPU.pciDeviceId}"
          "xe.force_probe=!${cfg.dGPU.pciDeviceId}"
        ]
        ++ lib.optionals (cfg.dGPU.intel.forceDriver == "xe") [
          "i915.force_probe=!${cfg.dGPU.pciDeviceId}"
          "xe.force_probe=${cfg.dGPU.pciDeviceId}"
        ];
    })
  ];
}
