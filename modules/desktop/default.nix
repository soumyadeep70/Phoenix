{ config, ... }:

{
  imports = [
    ./gnome
    ./hyprland
    ./plasma
  ];

  assertions = [
    {
      assertion =
        (lib.count (x: x) [
          config.phoenix.desktop.gnome.enable
          config.phoenix.desktop.plasma.enable
          config.phoenix.desktop.hyprland.enable
        ]) < 2;
      message = "At most 1 DE/WM is allowed";
    }
  ];
}
