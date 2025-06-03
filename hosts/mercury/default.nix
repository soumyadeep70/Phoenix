{ pkgs, ... }:

{
  phoenix = {
    identity = {
      host = "mercury";
      users = {
        cypher = {
          description = "Cypher";
          hashedPassword = "$6$J5fYkY20sdFX4BQK$WYYuSItnam.fDcv5uopCRYu.dGarOnUuOjHSpRoKhrxeqnyqFcEMzD5N6admfOnXjp6.xI6nHL9nXSjjbtIfn.";
        };
      };
    };
  };

  phoenix.system.kernel = {
    kernelVariant = pkgs.linuxKernel.packages.linux_xanmod_latest;
  };

  phoenix.system.hardware.gpu = {
    intel = [
      {
        codename = "KBL";
        pciDeviceId = "5916";
      }
    ];
  };

  phoenix.system.security = {
    enableTPM2 = true;
  };

  phoenix.system.desktop.plasma.enable = true;

  phoenix.profile = {
    development.enable = true;
    gaming.enable = true;
  };
}
