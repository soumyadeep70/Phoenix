{
  config,
  lib,
  pkgs,
  ...
}:

{
  home-manager.users = lib.genAttrs config.phoenix.user.usernames (name: {
    programs.git.enable = true;

    home.packages = with pkgs; [
      zed-editor-fhs
    ];
  });
}
