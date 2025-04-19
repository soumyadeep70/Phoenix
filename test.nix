let
  nixpkgs = import <nixpkgs>;
  pkgs = nixpkgs {
    config = {
      allowUnfree = true;
    };
  };
  lib = pkgs.lib;
in
builtins.elemAt
  (lib.mkMerge [
    {
      a = 2;
      b = [ "hi" ];
    }
    {
      b = [ "hello" ];
      c = 0;
    }
  ]).contents
  1
