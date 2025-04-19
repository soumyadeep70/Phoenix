{ config, lib, ... }:

let
  cfg = config.phoenix.system.security;
in
{
  options.phoenix.system.security = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable security settings";
      example = true;
    };
    enableTPM2 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable TPM2 (trusted platform module)";
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
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

    security.rtkit.enable = true;
    users.users = lib.genAttrs config.phoenix.user.usernames (name: {
      extraGroups = [ "realtime" ];
    });

    security.tpm2 = lib.mkIf cfg.enableTPM2 {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };
}
