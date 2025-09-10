{
    description = "Wyfy's NixOS flake";
    inputs = {
        nixpkgs.url ="nixpkgs/nixos-25.05";
        home-manager = {
             url = "github:nix-community/home-manager/release-25.05";
             inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager,  ... }: {
        nixosConfigurations.jormungandr = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.wyatt = import ./home.nix;
                        backupFileExtension = "backup";
                    };
                }
            ];
        };
    };
}
