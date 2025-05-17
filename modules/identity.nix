{
  config,
  lib,
  ...
}:

let
  cfg = config.phoenix.identity;
in
{
  options.phoenix.identity = {
    host = lib.mkOption {
      type = lib.types.strMatching "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$";
      default = "Phoenix";
      description = "Define hostname for linux system";
      example = "NixOS-PC";
    };
    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            description = lib.mkOption {
              type = lib.types.passwdEntry lib.types.str;
              description = "Description of the user, typically the full name";
            };
            hashedPassword = lib.mkOption {
              type = lib.types.passwdEntry lib.types.str;
              description = "Specify the hashed password generated using `mkpasswd -m sha-512`";
            };
            isNormalUser = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "This is always defined as true because this submodule only defines normal users";
              readOnly = true;
              visible = false;
            };
          };
        }
      );
      default = { };
      description = "Specify the users of the system";
      example = {
        bob = {
          description = "Bob Smith";
          hashedPassword = "$6$3gX5cVW3IxUB7lez$fUhCAFV0khSrYMOGJ//x9yHeucAdaw3KnUfNoVL5vSEseXvaD52n6/6t.b18nKGx7eXUlRX1TBQzJgXMvOJdM1";
        };
      };
    };
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.attrNames cfg.users;
      description = "List of usernames derived from phoenix.user.users";
      readOnly = true;
      visible = false;
    };
  };

  config = lib.mkIf ((builtins.length cfg.usernames) > 0) {
    networking.hostName = cfg.host;
    users.mutableUsers = false;
    users.users = cfg.users;
  };
}
