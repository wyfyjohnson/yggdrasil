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
        nixosConfigurations = let
            hmOpts = {
                home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    backupFileExtension = "backup";
                    users.wyatt = import ./home/wyatt;
                    };
                };
            in
            {
                fenrir = nixpkgs.lib.nixosSystem {
                    system = "x86_64-linux";
                    modules = [
                        ./host/fenrir/configuration.nix
                        # ./host/fenrir/hypr
                        home-manager.nixosModules.home-manager hmOpts
                    ];
                };
                jormungandr = nixpkgs.lib.nixosSystem {
                    system = "x86_64-linux";
                    modules = [
                        ./host/jormungandr/configuration.nix
                        # ./host/jormungandr/hypr.nix
                        home-manager.nixosModules.home-manager hmOpts
                    ];
                };
            };
    };
}
