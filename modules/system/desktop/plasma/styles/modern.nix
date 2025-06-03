{ config, lib, ... }:

{
  config = lib.mkIf (config.phoenix.system.desktop.plasma.style == "modern") {
    home-manager.users = lib.genAttrs config.phoenix.identity.usernames (name: {

    });
  };
}
