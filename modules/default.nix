{
  inputs,
  config,
  lib,
  phoenix-lib,
  ...
}:
{
  imports = builtins.filter (
    filePath: lib.strings.hasSuffix ".nix" filePath && filePath != (builtins.toString ./default.nix)
  ) (phoenix-lib.files.getFilesRecursive ./.);

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
    };
    sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
  };

  home-manager.users = lib.genAttrs config.phoenix.identity.usernames (name: {
    home.username = name;
    home.homeDirectory = "/home/${name}";
    home.stateVersion = "24.11";
  });
  system.stateVersion = "24.11";
}
