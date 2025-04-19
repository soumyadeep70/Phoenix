{ pkgs, ... }:

{
  phoenix.nix.enable = true;
  phoenix.system.kernel = {
    enable = true;
    kernelVariant = pkgs.linuxKernel.packages.linux_xanmod_latest;
  };
  phoenix.system.hardware = {
    enable = true;
    intel.iGPU = {
      enable = true;
      architecture = "Gen9";
      codename = "Kaby Lake";
      pciDeviceId = "5916";
    };
  };
  phoenix.system.localization.enable = true;
  phoenix.system.network.enable = true;
  phoenix.system.security = {
    enable = true;
    enableTPM2 = true;
  };
  phoenix.system.services.enable = true;
}
