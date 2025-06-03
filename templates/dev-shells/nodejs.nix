# Node.js development environment
# Usage: Copy to a project as shell.nix and create .envrc with "use nix"
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core Node.js environment
    nodejs_20
    nodePackages.npm
    nodePackages.pnpm
    
    # Development tools
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier
    
    # Optional: Uncomment tools you need
    # nodePackages.vite
    # nodePackages.yarn
  ];
  
  shellHook = ''
    echo "Node.js development environment activated"
    export PATH="$PWD/node_modules/.bin:$PATH"
    
    # Uncomment to automatically install dependencies
    # if [ ! -d "node_modules" ] && [ -f "package.json" ]; then
    #   echo "Installing dependencies..."
    #   npm install
    # fi
  '';
}
