{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {self, ...} @ inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      packages = {
        default = self.packages.${system}.assembler;
        assembler = pkgs.pkgsStatic.ocamlPackages.buildDunePackage {
          pname = "assembler";
          version = "0.0.0";
          src = ./.;
          buildInputs = [pkgs.ocamlPackages.cmdliner];
        };
      };
      devShells.default = pkgs.mkShell {
        inherit (self.packages.${system}.assembler) buildInputs;
        nativeBuildInputs = with pkgs; [
          dune_3
          ocamlPackages.ocaml
        ];
        shellHook = with pkgs; "${lib.getExe cloc} .";
      };
      formatter =
        (inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            ocamlformat.enable = true;
          };
        })
        .config
        .build
        .wrapper;
    });
}