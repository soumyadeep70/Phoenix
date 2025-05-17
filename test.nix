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
builtins.fromJSON ''
  {
    "editor": "nvim",
    "theme": "dark",
    "autosave": true,
    "plugins": [
      { "name": "lsp", "enabled": true },
      { "name": "tree-sitter", "enabled": true }
    ]
  }
''
