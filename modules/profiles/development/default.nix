{ config, lib, ... }:

let
  cfg = config.phoenix.profile.development;
in
{
  options.phoenix.profile.development = {
    type = lib.types.submodule {
      enable = lib.mkEnableOption "Development profile";

    };
    description = ''
      This is the development profile, which provides some
      useful applications and utilities for software development.
    '';
  };

  config = lib.mkIf cfg.enable {

  };
}
