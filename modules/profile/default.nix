{ config, lib, ... }:

{
  home-manager.users = lib.genAttrs config.phoenix.identity.usernames (name: {
    home.packages = [
      zed-editor-fhs
      jetbrains.clion
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      android-studio
    ];
  });
}
