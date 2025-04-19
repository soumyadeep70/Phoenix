{ config, lib, ... }:

let
  cfg = config.phoenix.desktop;
in
{
  imports = [
    ./plasma/themes/nord.nix
  ];

  options.phoenix.desktop = {
    gnome = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable GNOME";
            example = true;
          };
          theme = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Choose theme for GNOME";
            example = "";
          };
        };
      };
    };
    plasma = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Plasma";
            example = true;
          };
          theme = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Choose theme for Plasma";
            example = "nord";
          };
        };
      };
    };
    hyprland = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Hyprland";
            example = true;
          };
          theme = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Choose theme for Hyprland";
            example = "";
          };
        };
      };
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion =
            (lib.count (x: x) [
              cfg.gnome.enable
              cfg.plasma.enable
              cfg.hyprland.enable
            ]) < 2;
          message = "At most 1 DE/WM is allowed";
        }
      ];
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
