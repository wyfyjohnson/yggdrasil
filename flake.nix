{
  description = "Yggdrasil - Wyfy's cross-platform Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-darwin,
    home-manager,
    nix-darwin,
    ...
  }: let
    # home-manager configuration
    homeManagerConfig = {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.wyatt = ./home;
      };
    };

    # Helper function for NixOS systems
    mkNixosSystem = {
      system,
      hostname,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./host/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          homeManagerConfig
        ];
      };

    # Helper function for Darwin systems
    mkDarwinSystem = {
      system,
      hostname,
    }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./host/${hostname}/configuration.nix
          home-manager.darwinModules.home-manager
          homeManagerConfig
        ];
      };
  in {
    # NixOS Configurations
    nixosConfigurations = {
      fenrir = mkNixosSystem {
        system = "x86_64-linux";
        hostname = "fenrir";
      };
      jormungandr = mkNixosSystem {
        system = "x86_64-linux";
        hostname = "jormungandr";
      };
    };

    # Darwin Configurations
    darwinConfigurations = {
      hel = mkDarwinSystem {
        system = "aarch64-darwin";
        hostname = "hel";
      };
    };

    # Standalone Home Manager Configurations
    homeConfigurations = {
      "wyatt@linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [./home];
      };
      "wyatt@darwin" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-darwin {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        modules = [./home];
      };
    };
  };
}
