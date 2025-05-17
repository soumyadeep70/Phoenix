{ lib }:
/*
  *
  Every other nix files except default.nix should define
  functions related to that filename.
*/
let
  filenames = builtins.attrNames (
    lib.attrsets.filterAttrs (
      f: t: t == "regular" && lib.strings.hasSuffix ".nix" f && f != "default.nix"
    ) (builtins.readDir ./.)
  );
in
builtins.listToAttrs (
  builtins.map (name: {
    name = lib.strings.removeSuffix ".nix" name;
    value = import ./${name} { inherit lib; };
  }) filenames
)
