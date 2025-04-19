{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./system/boot
    ./system/kernel
    ./system/hardware
    ./system/security
    ./system/services
    ./system/network
    ./system/localization

    ./nix
    ./user

    ./desktop
    ./apps
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
  };

  home-manager.users = lib.genAttrs config.phoenix.user.usernames (name: {
    home.username = name;
    home.homeDirectory = "/home/${name}";
    home.stateVersion = "24.11";
  });
  system.stateVersion = "24.11";
}
