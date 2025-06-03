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
    enableAudio = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable audio";
      example = false;
    };
  };

  config = lib.mkMerge [
    {
      hardware.enableAllFirmware = true;
      services.fwupd.enable = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }

    (lib.mkIf cfg.enableBluetooth {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;
      };
    })

    (lib.mkIf cfg.enableAudio {
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
  ];
}
