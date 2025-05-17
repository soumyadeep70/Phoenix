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

  config = (
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
        users.users = lib.genAttrs config.phoenix.identity.usernames (name: {
          extraGroups = [ "audio" ];
        });
      })
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
