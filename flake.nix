{
  description = "Home Manager configuration of peter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ghostty,
    ...
  }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."peter" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
        ];

        # Optionally pass inputs on to other modules via extraSpecialArgs
        extraSpecialArgs = { inherit inputs; };
      };
    };
}

