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

        inherit (pkgs.stdenv) isAarch32 isAarch64 isDarwin;

        eig-drv = pkgs.stdenv.mkDerivation
          {
            name = "eigensoft";
            version = "8";
            src = ./.;

            NIX_CFLAGS_COMPILE = "-fcommon";

            buildInputs = [
              pkgs.gsl
              pkgs.openblas
            ] ++ (
              if isAarch64 && isDarwin then
                with pkgs.darwin.apple_sdk_11_0.frameworks; [
                  Accelerate
                  MetalKit
                ]
              else if isAarch32 && isDarwin then
                with pkgs.darwin.apple_sdk.frameworks; [
                  Accelerate
                  CoreGraphics
                  CoreVideo
                ]
              else if isDarwin then
                with pkgs.darwin.apple_sdk.frameworks; [
                  Accelerate
                  CoreGraphics
                  CoreVideo
                ]
              else [ ]
            );

            buildPhase = ''
              cd src
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
