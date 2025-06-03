# Rust development environment
# Usage: Copy to a project as shell.nix and create .envrc with "use nix"
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core Rust toolchain
    rustc
    cargo
    rustfmt
    clippy
    
    # Additional Cargo tools
    cargo-edit   # cargo add/rm/upgrade
    cargo-watch  # auto-recompilation
    cargo-audit  # security audit
    
    # Build dependencies
    pkg-config
    openssl.dev
  ];
  
  # Set up Rust environment variables
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  
  shellHook = ''
    echo "Rust development environment activated"
    
    # Uncomment to use a specific toolchain version
    # export RUSTUP_TOOLCHAIN=stable
    
    # Uncomment to enable backtraces for debugging
    # export RUST_BACKTRACE=1
  '';
}
