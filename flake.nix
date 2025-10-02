{
  description = "bevy-catppuccin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [(import rust-overlay)];
      pkgs = import nixpkgs {inherit system overlays;};

      rust = pkgs.rust-bin.stable.latest.default;

      bevyDeps =
        if pkgs.stdenv.isDarwin
        then [
          pkgs.freetype
          pkgs.fontconfig
          pkgs.vulkan-loader
        ]
        else [
          pkgs.udev
          pkgs.alsa-lib
          pkgs.vulkan-loader
          pkgs.xorg.libX11
          pkgs.xorg.libXcursor
          pkgs.xorg.libXi
          pkgs.xorg.libXrandr
          pkgs.libxkbcommon
          pkgs.wayland
          pkgs.egl-wayland
          pkgs.freetype
          pkgs.fontconfig
        ];
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [rust] ++ bevyDeps;
      };
    });
}
