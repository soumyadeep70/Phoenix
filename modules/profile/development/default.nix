{
  config,
  lib,
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
        zed-editor-fhs
        jetbrains.clion
        jetbrains.idea-ultimate
        jetbrains.pycharm-professional
        android-studio
      ];
    });
  };
}
