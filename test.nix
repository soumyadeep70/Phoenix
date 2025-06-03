let
  nixpkgs = import <nixpkgs>;
  pkgs = nixpkgs {
    config = {
      allowUnfree = true;
    };
  };
  lib = pkgs.lib;

  p-lib = import ./lib { inherit lib; };
in
builtins.toString ./modules
