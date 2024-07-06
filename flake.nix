{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        latestRust = pkgs.rust-bin.stable.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = latestRust;
          rustc = latestRust;
        };

        bin = rustPlatform.buildRustPackage {
          pname = "asak";
          version = "0.3.3";

          src = pkgs.fetchFromGitHub {
            owner = "chaosprint";
            repo = "asak";
            rev = "main";
            hash = "sha256-8Y1WXCAHGezXL1MRL6YAilsEIvgffKnANc12VQLd1bs=";
          };

          cargoHash = "sha256-ssHYQhx5rNkTH6KJuJh2wPcptIcIxP8BcDNriGj3btk=";

          buildInputs = [ pkgs.libjack2 pkgs.alsa-lib ];
          nativeBuildInputs = [ pkgs.pkg-config ];

          meta = with pkgs.lib; {
            description = "A cross-platform audio recording/playback CLI tool with TUI, written in Rust.";
            homepage = "https://github.com/chaosprint/asak";
            license = with licenses; [ mit ];
            maintainers = [ ];
          };
        };
      in
      {
        packages.default = bin;
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
