# Development Shell Templates

This directory contains template `shell.nix` files for common development environments. These templates make it easy to set up isolated, reproducible development environments for your projects using Nix and direnv.

## How to Use These Templates

1. Copy the appropriate template to your project directory:
   ```bash
   cp ~/nix-dotfiles/templates/dev-shells/python.nix ~/Projects/my-python-project/shell.nix
   ```

2. Create a `.envrc` file in your project directory:
   ```bash
   echo "use nix" > ~/Projects/my-python-project/.envrc
   ```

3. Allow direnv to use this configuration:
   ```bash
   cd ~/Projects/my-python-project
   direnv allow
   ```

4. Customize the `shell.nix` file for your project's specific needs.

## Available Templates

- **nodejs.nix**: Node.js development environment with TypeScript, ESLint, and Prettier
- **python.nix**: Python development environment with virtualenv, pyright, and ruff
- **rust.nix**: Rust development environment with cargo tools and build dependencies
- **go.nix**: Go development environment with gopls, linting, and debugging tools
- **fullstack.nix**: Combined environment for full-stack development (Node.js + Python)

## Customizing Templates

Each template includes commented sections that you can uncomment to enable additional features:
- Automatic dependency installation
- Project-specific configurations
- Optional tools and packages

## Benefits of This Approach

- **Isolation**: Each project has its own dependencies, avoiding conflicts
- **Reproducibility**: Same environment works across different machines
- **Automatic activation**: Environment loads when you enter the directory
- **No global pollution**: Dependencies don't clutter your global environment

## Adding New Templates

Feel free to add new templates for other development environments as needed. Follow the same pattern of:
1. Core tools and runtimes
2. Development tools (LSPs, linters, etc.)
3. A helpful shellHook with environment setup
