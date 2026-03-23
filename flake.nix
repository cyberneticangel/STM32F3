{
  description = "A Nix flake for STM32F3 Discovery Rust development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        # Choose a recent stable Rust toolchain with the necessary target
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = [ "thumbv7em-none-eabihf" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            # Core embedded development tools
            probe-rs-tools  # For flashing and debugging
            cargo-binutils  # For binary inspection (e.g., `rust-objdump`)
            openocd         # Alternative debug server
            gdb             # For debugging with OpenOCD
            
            # Optional but recommended utilities
            cargo-generate  # For creating new projects from templates
            rust-analyzer   # IDE support
          ];

          # Environment variables for a seamless experience
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          
          shellHook = ''
            echo "STM32F3 Discovery Rust development environment loaded."
            echo "Target: thumbv7em-none-eabihf (Cortex-M4F with FPU)"
            echo ""
            echo "Common commands:"
            echo "  cargo build --target thumbv7em-none-eabihf"
            echo "  cargo embed (with an Embed.toml config)"
            echo "  probe-rs list (to see connected devices)"
          '';
        };
      });
}
