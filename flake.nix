{
  description = "Phoenix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      # ===== Architecture =====
      system = "x86_64-linux";

      # ===== Nixpkgs pkgs =====
      pkgs = nixpkgs.legacyPackages.${system};

      # ===== Nixpkgs lib =====
      lib = pkgs.lib;

      # ===== Custom pkgs =====
      phoenix-pkgs = import ./pkgs { inherit lib pkgs; };

      # ===== Custom lib =====
      phoenix-lib = import ./lib { inherit lib; };
    in
    {
      nixosConfigurations = lib.attrsets.genAttrs (phoenix-lib.files.getDirs ./hosts) (
        host:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs phoenix-lib phoenix-pkgs;
          };
          modules = [
            ./modules
            ./hosts/${host}
            /etc/nixos/hardware-configuration.nix
          ];
        }
      );

      formatter.${system} = (inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper;

      checks.${system} = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
          };
        };
        formatting = (inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.check self;
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };

      optionsDoc =
        (pkgs.nixosOptionsDoc {
          options =
            let
              randomHost = builtins.head (builtins.attrNames (self.nixosConfigurations));
            in
            self.nixosConfigurations.${randomHost}.options.phoenix;
        }).optionsCommonMark;
    };
}
