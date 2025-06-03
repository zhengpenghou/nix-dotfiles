# Python development environment
# Usage: Copy to a project as shell.nix and create .envrc with "use nix"
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core Python environment
    python311
    python311Packages.pip
    python311Packages.virtualenv
    uv  # Modern Python package installer
    
    # Development tools
    pyright  # Type checking
    ruff     # Linter and formatter
    
    # Common libraries - uncomment as needed
    # python311Packages.numpy
    # python311Packages.pandas
    # python311Packages.requests
    # python311Packages.pytest
    # python311Packages.flask
    # python311Packages.fastapi
    # python311Packages.sqlalchemy
  ];
  
  shellHook = ''
    echo "Python development environment activated"
    
    # Create and activate virtualenv if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating virtual environment..."
      python -m venv .venv
    fi
    source .venv/bin/activate
    
    # Uncomment to automatically install dependencies
    # if [ -f "requirements.txt" ]; then
    #   echo "Installing dependencies..."
    #   uv pip install -r requirements.txt
    # fi
    
    # Set PYTHONPATH to include the current directory
    export PYTHONPATH=$PWD:$PYTHONPATH
  '';
}
