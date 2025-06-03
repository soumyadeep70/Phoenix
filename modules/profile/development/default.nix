{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.phoenix.profile.development;
in
{
  options.phoenix.profile.development = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable development profile";
      example = true;
    };
  };

  config.specialisation.development.configuration = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.phoenix.identity.usernames (name: {
      home.packages = [
        jetbrains.clion
        # jetbrains.idea-ultimate
        # jetbrains.pycharm-professional
        # android-studio
        pkgs.zed-editor-fhs
      ];

      programs.git = {
        enable = true;
        userName = "soumyadeep70";
        userEmail = "soumyadeepdash70@gmail.com";
      };
    });
  };
}
