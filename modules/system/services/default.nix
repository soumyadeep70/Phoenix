{ config, lib, ... }:

let
  cfg = config.phoenix.system.services;
in
{
  options.phoenix.system.services = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable services";
      example = true;
    };
    enableMultimediaStreaming = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable audio and video streaming";
      example = false;
    };
    enablePowerManagement = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable power management to optimize temperature and power usage";
      example = false;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.enableMultimediaStreaming {
        services.pipewire = {
          enable = true;
          wireplumber.enable = true;
          pulse.enable = true;
          jack.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
        };
        users.users = lib.genAttrs config.phoenix.user.usernames (name: {
          extraGroups = [ "audio" ];
        });
      })
      (lib.mkIf cfg.enablePowerManagement {
        services.power-profiles-daemon.enable = lib.mkForce false;
        services.auto-cpufreq.enable = true;
        services.thermald = {
          enable = true;
          ignoreCpuidCheck = true;
        };
      })
    ]
  );
}
