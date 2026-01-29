{
  description = "Yggdrasil - Wyfy's cross-platform Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    wfetch.url = "github:iynaix/wfetch";
    huginn.url = "github:wyfyjohnson/huginn";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-darwin,
    nix-darwin,
    wfetch,
    huginn,
    ...
  }: let
    # Helper function for NixOS systems
    mkNixosSystem = {
      system,
      hostname,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit hostname wfetch huginn;
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./host/${hostname}/configuration.nix
        ];
      };

    # Helper function for Darwin systems
    mkDarwinSystem = {
      system,
      hostname,
    }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit hostname wfetch huginn;
          unstable = import nixpkgs-darwin {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./host/${hostname}/configuration.nix
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
  };
}
