{
  description = "Phoenix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.phoenix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./modules
          ./specializations
          /etc/nixos/hardware-configuration.nix
          inputs.home-manager.nixosModules.home-manager
        ];
      };
      optionsDoc =
        (pkgs.nixosOptionsDoc {
          options = self.nixosConfigurations.phoenix.options.phoenix;
        }).optionsCommonMark;
    };
}
