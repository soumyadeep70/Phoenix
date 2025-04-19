{ lib, ... }:

let
  dirContents = builtins.readDir ./.;
  specializations = builtins.attrNames (lib.filterAttrs (n: v: v == "directory") dirContents);
  specializationConfigs = builtins.listToAttrs (
    builtins.map (dir: {
      name = dir;
      value = {
        configuration = {
          imports = [ ./${dir} ];
        };
      };
    }) specializations
  );
in
{
  imports = [
    ./base.nix
  ];

  specialisation = specializationConfigs;
}
