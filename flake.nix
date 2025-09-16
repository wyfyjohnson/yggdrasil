{
  description = "Yggdrasil - Wyfy's cross-platform Nix configuration";

  inputs = {
    # Use stable branches for all inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin support
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin,
      home-manager,
      nix-darwin,
      ...
    }:
    {
      # NixOS Configurations
      nixosConfigurations = {
        fenrir = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./host/fenrir/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.wyatt = ./home/wyatt;
            }
          ];
        };

        jormungandr = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./host/jormungandr/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.wyatt = ./home/wyatt;
            }
          ];
        };
      };

      # Darwin Configurations (macOS)
      darwinConfigurations = {
        hel = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./host/hel/configuration.nix

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.wyatt = ./home/wyatt;
            }
          ];
        };
      };

      # Standalone Home Manager Configurations
      homeConfigurations = {
        "wyatt@linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [ ./home/wyatt ];
        };

        "wyatt@darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-darwin {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          modules = [ ./home/wyatt ];
        };
      };
    };
}
