{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-easyeffects.url = "github:nixos/nixpkgs/d4bbd6814a5f9988d1cd43abca69a43e124fe81b";
    nixpkgs-telegram.url = "github:nixos/nixpkgs/b3c092d3c36d91e2f61f3dfb39a159f180a56659";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-easyeffects,
      nixpkgs-telegram,
      disko,
      nix-index-database,
      agenix,
      home-manager,
      nix-vscode-extensions,
      ...
    }:
    let
      system = "x86_64-linux";
      root = ./.;
      secretsDir = root + "/secrets";

      pkgsWithVscodeExtensions = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          nix-vscode-extensions.overlays.default
        ];
      };

      custom = {
        packages = {
          easyeffects = (import nixpkgs-easyeffects { inherit system; }).easyeffects;
          telegram-desktop = (import nixpkgs-telegram { inherit system; }).telegram-desktop;
          agenix = agenix.packages.${system}.default;
          community-vscode-extensions = pkgsWithVscodeExtensions.vscode-marketplace;
        };

        lib = {
          fromRoot = path: root + path;
          fromSecretsDir = path: secretsDir + path;
        };
      };
    in
    {
      nixosConfigurations = {
        ixliynez-pc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit custom;
          };

          modules = [
            ./configuration.nix
            disko.nixosModules.disko
            nix-index-database.nixosModules.default
            agenix.nixosModules.default

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit custom;
                };
                backupFileExtension = ".hm-backup";
                users.ixliynez = import ./home/ixliynez/ixliynez.nix;
              };
            }
          ];
        };
      };
    };
}
