{
  description = "Wyfy's NixOS flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    # nvf.url = "github:notashelf/nvf";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  }:
  # outputs = { self, nixpkgs, home-manager, nvf,  ... }: {
  let
    hmOpts = {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.wyatt = import ./home/wyatt;
      };
    };
  in {
    nixosConfigurations = {
      fenrir = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/fenrir/configuration.nix
          # ./host/fenrir/hypr
          home-manager.nixosModules.home-manager
          hmOpts
        ];
      };
      jormungandr = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/jormungandr/configuration.nix
          # ./host/jormungandr/hypr.nix
          # nvf.homeManagerModules.default
          home-manager.nixosModules.home-manager
          hmOpts
        ];
      };
    };

    darwinConfigurations = {
      hel = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          hmOpts
          ./host/hel/home.nix
        ];
      };
    };
  };
}
