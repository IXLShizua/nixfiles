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

    codex-mcp-serena.url = "github:oraios/serena";
    codex-mcp-serena.inputs.nixpkgs.follows = "nixpkgs";

    codex-mcp-codebase-memory-mcp.url = "github:DeusData/codebase-memory-mcp";
    codex-mcp-codebase-memory-mcp.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
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
      codex-mcp-serena,
      codex-mcp-codebase-memory-mcp,
      lanzaboote,
      ...
    }:
    let
      system = "x86_64-linux";
      root = ./.;
      secretsDir = root + "/secrets";

      mkPkgs =
        pkgs:
        import pkgs {
          inherit system;
          config.allowUnfree = true;
        };

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
          easyeffects = (mkPkgs nixpkgs-easyeffects).easyeffects;
          telegram-desktop =
            (mkPkgs nixpkgs).callPackage ./home/ixliynez/packages/telegram-with-webview.nix
              { };
          agenix = agenix.packages.${system}.default;
          community-vscode-extensions = pkgsWithVscodeExtensions.vscode-marketplace;

          artcraft = {
            wordcraft = (mkPkgs nixpkgs).callPackage ./home/ixliynez/packages/artcraft/wordcraft.nix { };
            deckcraft = (mkPkgs nixpkgs).callPackage ./home/ixliynez/packages/artcraft/deckcraft.nix { };
          };

          codex-mcp-serena = codex-mcp-serena.packages.${system}.default;
          codex-mcp-codebase-memory-mcp = codex-mcp-codebase-memory-mcp.packages.${system}.default;
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
            lanzaboote.nixosModules.lanzaboote

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
