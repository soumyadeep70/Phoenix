{ config, lib, ... }:

{
  home-manager.users = lib.genAttrs config.phoenix.user.usernames (name: {
    programs.firefox.enable = true;
  });
}
