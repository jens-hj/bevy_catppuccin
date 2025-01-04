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

  outputs =
    { self
    , nixpkgs
    , rust-overlay
    , flake-utils
    , ...
    } @ inputs:
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

      bevy-deps = with pkgs; [
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
      cargo-subcommands = with pkgs; [
        cargo-bloat
        cargo-expand
        cargo-outdated
        cargo-show-asm
        cargo-make
        cargo-modules
        cargo-nextest
        cargo-rr
        cargo-udeps
        cargo-watch
        cargo-wizard
        cargo-pgo
        cargo-flamegraph
        cargo-license
        cargo-release
      ];
      rust-deps = with pkgs;
        [
          taplo # TOML formatter and LSP
          bacon
          mold # A Modern Linker
          clang # For linking
          trunk # rust wasm bundler
          wasm-bindgen-cli
          sass
          tailwindcss
        ]
        ++ cargo-subcommands;
      dev-deps = with pkgs; [
        just
        typos # spell checker
        gh
      ];
    in
    with pkgs; {
      formatter.${system} = pkgs.alejandra;
      devShells.default = pkgs.mkShell rec {
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs =
          [
            (
              rust-bin.selectLatestNightlyWith (toolchain:
                toolchain.default.override {
                  extensions =
                    rust-extensions
                    ++ [
                      "rustc-codegen-cranelift-preview"
                    ];
                  targets = [ "wasm32-unknown-unknown" ];
                })
            )
          ]
          ++ bevy-deps
          ++ rust-deps
          ++ dev-deps;

        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
      };
    });
}
