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
      ocamlPackages' = pkgs.pkgsMusl.ocamlPackages.overrideScope (_: super: {
        ocaml = super.ocaml.override {flambdaSupport = true;};
      });
    in {
      packages = {
        default = self.packages.${system}.assembler;
        assembler = ocamlPackages'.buildDunePackage {
          pname = "assembler";
          version = "0.0.0";
          src = ./.;
          buildInputs = with ocamlPackages'; [base ppx_sexp_conv sexplib stdio];
        };
      };
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs.ocamlPackages; [base ppx_sexp_conv sexplib stdio];
        nativeBuildInputs =
          [pkgs.opam]
          ++ (with pkgs.ocamlPackages; [
            dune_3
            findlib
            ocaml-lsp
            ocamlformat
            ocaml
          ]);
        shellHook = with pkgs; ''
          ${lib.getExe cloc} --vcs git --hide-rate --quiet .
          dune build
        '';
      };
      formatter =
        (inputs.treefmt-nix.lib.evalModule pkgs {
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            ocamlformat.enable = true;
          };
        })
        .config
        .build
        .wrapper;
    });
}
