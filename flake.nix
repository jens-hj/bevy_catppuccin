{
  description = "vienas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import inputs.nixpkgs { inherit system overlays; };
        rust-extensions = [
          "rust-src"
          "rust-analyzer"
          "llvm-tools-preview" # used with `cargo-pgo`
        ];
        rust-additional-targets = [ "wasm32-unknown-unknown" ];

        bevy-deps = with pkgs;
          if stdenv.isDarwin then [
            vulkan-loader
            freetype
            fontconfig
          ] else [
            udev
            alsa-lib
            vulkan-loader
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXrandr
            libxkbcommon
            wayland
            egl-wayland
            freetype
            fontconfig
          ];
        cargo-subcommands = with pkgs; [ cargo-release ];
        rust-deps = with pkgs;
          [
            # rustup
            taplo # TOML formatter and LSP
            bacon
            mold # A Modern Linker
            clang # For linking
            ra-multiplex
            trunk # rust wasm bundler
            openssl
            gcc
            gfortran
            zlib
          ] ++ cargo-subcommands;
        dev-deps = with pkgs; [
          just
          typos # spell checker
          act # run github actions local in a docker container
          gh
        ];
      in with pkgs; {
        formatter.${system} = pkgs.alejandra;
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            pkgs.darwin.apple_sdk.frameworks.CoreFoundation
          ] ++ [
            (rust-bin.selectLatestNightlyWith (toolchain:
              toolchain.default.override {
                extensions = rust-extensions
                  ++ [ "rustc-codegen-cranelift-preview" ];
                targets = [ "wasm32-unknown-unknown" ];
              }))
          ] ++ bevy-deps ++ rust-deps ++ dev-deps;

          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
        };
      });
}
