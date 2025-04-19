{ config, lib, ... }:

let
  cfg = config.phoenix.user;
in
{
  options.phoenix.user = {
    users = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Define full name / description of the user";
            };
            username = lib.mkOption {
              type = lib.types.strMatching "[a-z_][a-z0-9_-]*";
              description = "Define username for linux system";
            };
            initialPassword = lib.mkOption {
              type = lib.types.str;
              description = "Define the initial password";
            };
          };
        }
      );
      default = [ ];
      description = "Specify the users of the system";
      example = [
        {
          name = "Bob Smith";
          username = "bob";
          initialPassword = "12345";
        }
      ];
    };
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      visible = false;
      default = builtins.map (user: user.username) cfg.users;
      description = "List of usernames derived from phoenix.user.users";
    };
  };

  config = lib.mkIf ((builtins.length cfg.users) > 0) {
    users.users = builtins.listToAttrs (
      builtins.map (user: {
        name = user.username;
        value = {
          createHome = true;
          isNormalUser = true;
          description = user.name;
          initialPassword = user.initialPassword;
          extraGroups = [ "wheel" ];
        };
      }) cfg.users
    );
  };
}
