# Full-stack development environment (Node.js + Python)
# Usage: Copy to a project as shell.nix and create .envrc with "use nix"
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Node.js environment
    nodejs_20
    nodePackages.npm
    nodePackages.pnpm
    nodePackages.typescript
    nodePackages.typescript-language-server
    
    # Python environment
    python311
    python311Packages.pip
    uv
    pyright
    
    # Database tools
    postgresql_15
    
    # Development tools
    jq
    httpie
    
    # Docker (if needed)
    # docker
    # docker-compose
  ];
  
  shellHook = ''
    echo "Full-stack development environment activated"
    
    # Node.js setup
    export PATH="$PWD/node_modules/.bin:$PATH"
    
    # Python setup
    if [ ! -d ".venv" ]; then
      echo "Creating Python virtual environment..."
      python -m venv .venv
    fi
    source .venv/bin/activate
    
    # Environment variables
    export DEVELOPMENT=true
    
    # Uncomment to start services automatically
    # echo "Starting development services..."
    # docker-compose up -d
  '';
}
