{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "switch-profile" ''
      #!/usr/bin/env bash

    '')
  ];

  home-manager.users = lib.genAttrs config.phoenix.identity.usernames (name: {
    programs.firefox.enable = true;
  });
}
