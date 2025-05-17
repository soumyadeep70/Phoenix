{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.phoenix.system.kernel;
in
{
  options.phoenix.system.kernel = {
    kernelVariant = lib.mkOption {
      type = lib.types.attrs;
      default = pkgs.linuxKernel.packages.linux_6_14;
      defaultText = "pkgs.linuxKernel.packages.linux_6_14";
      description = "Choose which kernel to use";
      example = "pkgs.linuxKernel.packages.linux_zen";
    };
    enableAppimageSupport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for Appimage binary format";
      example = true;
    };
  };

  config = {
    boot = {
      kernelPackages = cfg.kernelVariant;
      kernelParams = [
        "boot.shell_on_fail"
        "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"
        "usbcore.autosuspend=-1"
        "security=selinux"
      ];
    };

    programs.appimage = lib.mkIf cfg.enableAppimageSupport {
      enable = true;
      binfmt = true;
    };
  };
}
