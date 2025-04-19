{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.phoenix.system.boot;
in
{
  options.phoenix.system.boot = {
    # TODO: grub theme configuration
    graphicalBoot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable graphical boot screen";
      };
      # TODO: plymouth themes configuration
    };
  };

  config = {
    boot.initrd = {
      enable = true;
      systemd.enable = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
      memtest86.enable = true;
      copyKernels = true;
    };
    environment.systemPackages = [ pkgs.efibootmgr ];

    boot.plymouth.enable = lib.mkIf cfg.graphicalBoot.enable true;
  };
}
