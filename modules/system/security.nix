{
  config,
  lib,
  ...
}:
let
  cfg = config.phoenix.system.security;
in
{
  options.phoenix.system.security = {
    enablePolkit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable security settings";
      example = true;
    };
    enableTPM2 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable TPM2 (trusted platform module)";
      example = true;
    };
    enableRealtimeScheduling = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable realtime scheduling policy via rtkit";
      example = true;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enablePolkit {
      security.polkit = {
        enable = true;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
              if (
                  subject.isInGroup("users")
                      && (
                          action.id == "org.freedesktop.login1.reboot" ||
                          action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                          action.id == "org.freedesktop.login1.power-off" ||
                          action.id == "org.freedesktop.login1.power-off-multiple-sessions"
                      )
                  )
              {
                  return polkit.Result.YES;
              }
          })
        '';
      };
    })
    (lib.mkIf cfg.enableTPM2 {
      security.tpm2 = {
        enable = true;
        pkcs11.enable = true;
        tctiEnvironment.enable = true;
      };
    })
    (lib.mkIf cfg.enableRealtimeScheduling {
      security.rtkit.enable = true;
      users.users = lib.genAttrs config.phoenix.user.usernames (name: {
        extraGroups = [ "realtime" ];
      });
    })
  ];
}
