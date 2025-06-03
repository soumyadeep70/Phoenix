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

      SPECIALISATION_DIR="/nix/var/nix/profiles/system/specialisation"

      if [[ ! -d "$SPECIALISATION_DIR" ]]; then
          echo "Error: No specialisations found at $SPECIALISATION_DIR"
          exit 1
      fi

      echo "Available specialisations:"
      specialisations=($(ls "$SPECIALISATION_DIR"))
      select spec in "''${specialisations[@]}"; do
          if [[ -n "$spec" ]]; then
              echo "Switching to specialisation: $spec"
              sudo "$SPECIALISATION_DIR/$spec/bin/switch-to-configuration" switch
              exit $?
          else
              echo "Invalid choice."
          fi
      done
    '')
  ];

  home-manager.users = lib.genAttrs config.phoenix.identity.usernames (name: {
    home.packages = with pkgs; [
      brave
    ];
  });
}
