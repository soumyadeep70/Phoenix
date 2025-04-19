{ config, lib, ... }:

let
  cfg = config.phoenix.nix;
in
{
  options.phoenix.nix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable some NixOS settings and optimization";
      example = true;
    };
    enableGC = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable garbage collection regularly";
      example = true;
    };
  };

  config = lib.mkMerge [
    {
      nixpkgs.config.allowUnfree = true;
      nix.settings = {
        trusted-users = [ "@wheel" ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
    }
    (lib.mkIf cfg.enableGC {
      nix.optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    })
  ];
}
