{
  config,
  lib,
  ...
}:
{
  assertions = [
    {
      assertion =
        (lib.count (x: x) (
          builtins.map (x: config.phoenix.system.desktop.${x}.enable) (
            builtins.attrNames config.phoenix.system.desktop
          )
        )) <= 1;
      message = "At most 1 DE/WM is allowed";
    }
  ];
}
