{ config, lib, ... }:

let
  cfg = config.phoenix.desktop;
in
{
  options.phoenix.desktop = {
    
  };

  config = lib.mkMerge [
    {
      
    }
    (lib.mkIf cfg.gnome.enable {
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
    })
    (lib.mkIf cfg.plasma.enable {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
    })
    (lib.mkIf cfg.hyprland.enable {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };
    })
  ];
}
