{
  description = "EIGENSOFT v8";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        eig-drv = pkgs.stdenv.mkDerivation
          {
            name = "eigensoft";
            version = "8";
            src = ./src;

            NIX_CFLAGS_COMPILE = "-fcommon";

            buildPhase = ''
              make install
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp -r ../bin/* $out/bin
            '';

          };
      in
      rec
      {

        packages.default = eig-drv;

      });
}
