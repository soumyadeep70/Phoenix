{
  lib,
  pkgs,
}:
/*
  *
  addition directory:
  - This directory should contain only .nix files
      which defines new packages.
  modification directory:
  - This directory should contain only .nix files
      which overrides the existing packages in nixpkgs.
*/
let
  fileNames =
    dir:
    builtins.attrNames (
      lib.attrsets.filterAttrs (f: t: t == "regular" && lib.strings.hasSuffix ".nix" f) (
        builtins.readDir dir
      )
    );
in
builtins.listToAttrs (
  builtins.map (name: {
    name = lib.strings.removeSuffix ".nix" name;
    value = pkgs.callPackage ./addition/${name} { };
  }) (fileNames ./addition)
  ++ builtins.map (name: {
    name = lib.strings.removeSuffix ".nix" name;
    value = import ./modification/${name} { inherit pkgs; };
  }) (fileNames ./modification)
)
