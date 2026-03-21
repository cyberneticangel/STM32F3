{
  description = "Rust development environment for STM32 F3 Discovery";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, fenix, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) fenix.overlays.default ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        
        # Target for STM32F3 (Cortex-M4)
        target = "thumbv7em-none-eabihf";
        
        # Rust toolchain with necessary components
        rustToolchain = fenix.packages.${system}.complete.withComponents [
          "rustc"
          "cargo"
          "rustfmt"
          "clippy"
          "rust-src"
          "llvm-tools"
          "rust-analyzer"
        ];
        
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            
            # Embedded build tools
            gcc-arm-embedded
            openocd
            gdb
            probe-rs
            cargo-binutils
            cargo-flash
            cargo-embed
            
            # Additional utilities
            cmake
            make
            python3
            git
            
            # For debugging and analysis
            ltrace
            strace
            
            # Optional: for generating documentation
            graphviz
          ];
          
          # Environment variables
          shellHook = ''
            export RUSTC_VERSION=$(rustc --version)
            export RUSTUP_TOOLCHAIN=stable
            export CARGO_TARGET_DIR=target
            
            # Add target for STM32F3
            rustup target add thumbv7em-none-eabihf
            
            # Install cargo-generate for project templates
            cargo install cargo-generate 2>/dev/null || true
            
            echo "🔥 Rust development environment for STM32 F3 Discovery"
            echo "Target: $target"
            echo "Rust version: $RUSTC_VERSION"
            echo ""
            echo "Available commands:"
            echo "  cargo build --target $target"
            echo "  cargo run --target $target"
            echo "  cargo flash --target $target --chip STM32F303VCTx"
            echo "  openocd -f interface/stlink.cfg -f target/stm32f3x.cfg"
            echo ""
          '';
          
          # Set up cargo config
          CARGO_HOME = "./.cargo";
        };
      });
}
