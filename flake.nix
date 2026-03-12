{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-easyeffects.url = "github:nixos/nixpkgs/d4bbd6814a5f9988d1cd43abca69a43e124fe81b";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-easyeffects,
      disko,
      nix-index-database,
      agenix,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs-easyeffects = import nixpkgs-easyeffects { inherit system; };
      agenixDefault = agenix.packages."${system}".default;
    in
    {
      nixosConfigurations = {
        ixliynez-pc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit agenixDefault;

            customSecretsPath = ./secrets;
          };

          modules = [
            ./system/disk-config.nix
            ./configuration.nix
            disko.nixosModules.disko
            nix-index-database.nixosModules.default
            agenix.nixosModules.default

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit pkgs-easyeffects;
                };
                backupFileExtension = ".hm-backup";
                users.ixliynez = import ./home/ixliynez.nix;
              };
            }
          ];
        };
      };
    };
}
