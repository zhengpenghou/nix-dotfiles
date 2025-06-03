# Go development environment
# Usage: Copy to a project as shell.nix and create .envrc with "use nix"
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core Go toolchain
    go
    
    # Development tools
    gopls          # Go language server
    golangci-lint  # Linter
    delve          # Debugger
    go-tools       # Additional tools like godoc, etc.
    
    # Build tools
    gnumake
  ];
  
  shellHook = ''
    echo "Go development environment activated"
    
    # Set up GOPATH if using modules
    export GOPATH="$PWD/.go"
    export PATH="$GOPATH/bin:$PATH"
    export GO111MODULE=on
    
    # Create necessary directories
    mkdir -p .go/bin
    
    # Uncomment to automatically install tools
    # go install golang.org/x/tools/cmd/goimports@latest
  '';
}
