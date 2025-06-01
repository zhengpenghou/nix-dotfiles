{ pkgs, config, lib, inputs, currentUser, currentSystem, ... }:

let
  isMacOS = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # --- VS Code / Cursor Extensions (Define once) ---
  commonExtensions = with pkgs.vscode-extensions; [
    bbenoist.nix # Nix
    jnoortheen.nix-ide
    editorconfig.editorconfig # EditorConfig
    gitlens.gitlens # GitLens
    # Python
    ms-python.python
    ms-python.vscode-pylance # Note: Pylance has a license
    charliermarsh.ruff # Ruff linter/formatter
    # TypeScript / JavaScript
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    # Rust
    rust-lang.rust-analyzer
    serayuzgur.crates
    # Go
    golang.go
    # Themes, etc.
    # dracula-theme.theme-dracula # Example theme
  ];

  # Windsurf IDE - Handling (see notes below)
  windsurfPackages =
    if isLinux then [
      # Example if you have a packaged .deb or can extract an AppImage:
      # (pkgs.callPackage ./path/to/windsurf-package.nix {})
    ] else if isMacOS then [
      # Example if you have a .dmg or .app packaged:
      # (pkgs.callPackage ./path/to/windsurf-package.nix {})
    ] else [];


in
{
  # This is crucial for Home Manager to know which version's behavior to expect.
  # Update this as you update Home Manager itself and review release notes.
  home.stateVersion = "25.05"; # Or current stable, e.g., "23.11"

  # Set username and home directory (can be overridden by NixOS module if needed)
  home.username = currentUser;
  home.homeDirectory = if isMacOS then "/Users/${currentUser}" else "/home/${currentUser}";

  programs.home-manager.enable = true; # Manages itself

  # --- Packages ---
  home.packages = [
    # Essentials
    pkgs.git
    pkgs.gnupg
    pkgs.htop
    pkgs.jq # JSON processor
    pkgs.ripgrep # Fast search
    pkgs.fd # Fast find
    pkgs.eza # Modern ls
    pkgs.bat # Modern cat with syntax highlighting
    pkgs.gh # GitHub CLI

    # Development Languages & Tools
    pkgs.python311 # Specific Python version
    pkgs.uv      # Python packager
    pkgs.nodejs_20 # Node.js LTS
    pkgs.yarn      # Or pkgs.pnpm, pkgs.nodePackages.npm
    pkgs.go        # Go language

    # IDEs / Editors
    pkgs.vscode-insiders
    # pkgs.cursor # Check if `cursor` exists in nixpkgs: search.nixos.org/packages
                  # If not, manual install or custom package needed.
  ] ++ windsurfPackages; # Add Windsurf if packaged

  # --- Rust ---
  programs.rustup = {
    enable = true;
    toolchains = [ "stable" "nightly" ];
    defaultToolchain = "stable";
    components = [ "rust-src" "clippy" "rustfmt" ];
    # target = "wasm32-unknown-unknown"; # Example target
  };

  # --- Shell (Example: Fish) ---
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -x EDITOR nvim # Or code, or your preferred editor
      # Fish aliases and functions
      alias ls='eza --git --icons'
      alias cat='bat'
    '';
    # plugins = [ ... ];
  };
  # If you use Bash, configure `programs.bash` instead or additionally.

  # --- Git ---
  programs.git = {
    enable = true;
    userName = "Zhengpeng Hou"; # Replace
    userEmail = "zhengpeng.hou@gmail.com"; # Replace
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      # Alias examples
      "alias.st" = "status -sb";
      "alias.co" = "checkout";
      "alias.br" = "branch";
      "alias.ci" = "commit";
    };
    signing = {
      key = FF5180A308BCE444BDA6FA4D49E1ED6DE3D83CCB; # Your GPG key ID if you use commit signing
      signByDefault = true;
    };
  };

  # --- VS Code ---
    programs.vscode = {
    enable = true;
    package = pkgs.vscode-insiders; # Use VS Code Insiders
    extensions = commonExtensions;   # Your defined list of extensions

    userSettings = {
      # Your settings from JSON:
      "workbench.colorTheme" = "Default Light Modern";
      "redhat.telemetry.enabled" = false; # Assuming redhat.java or similar extension is installed
      "github.copilot.advanced" = {}; # Empty attrset for an empty JSON object
      "github.copilot.chat.followUps" = "always";
      "github.copilot.chat.localeOverride" = "en";
      "github.copilot.nextEditSuggestions.enabled" = true;
      "github.copilot.chat.codesearch.enabled" = true;
      "github.copilot.chat.agent.thinkingTool" = true;
      "github.copilot.chat.generateTests.codeLens" = true;
      "github.copilot.chat.languageContext.fix.typescript.enabled" = true;
      "github.copilot.chat.languageContext.inline.typescript.enabled" = true;
      "github.copilot.chat.languageContext.typescript.enabled" = true;
      "github.copilot.chat.codeGeneration.useInstructionFiles" = true;
      "roo-cline.allowedCommands" = [
        "npm test"
        "npm install"
        "tsc"
        "git log"
        "git diff"
        "git show"
        "cat"
      ];

      # You can merge these with your other existing userSettings:
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
      "editor.formatOnSave" = true;
      "files.autoSave" = "afterDelay";
      "workbench.startupEditor" = "none";

      "[nix]" = { "editor.defaultFormatter" = "bbenoist.nix"; };
      "[python]" = { "editor.defaultFormatter" = "charliermarsh.ruff"; };
      "[rust]" = { "editor.defaultFormatter" = "rust-lang.rust-analyzer"; };
      "[typescript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "[go]" = { "editor.defaultFormatter" = "golang.go"; "editor.formatOnSave" = true; };
    };
  };

  # ... other configurations like Cursor, Windsurf, dotfiles, env variables ...
  nixpkgs.config.allowUnfree = true; # Ensure this is true if Copilot or other extensions are unfree
}
  # --- Cursor IDE ---
  # If `pkgs.cursor` exists and you added it to home.packages:
  # You might need to manage its settings via `home.file` if no dedicated HM module exists.
  # E.g., home.file.".config/Cursor/settings.json".text = builtins.toJSON { /* your settings */ };

  # --- Windsurf IDE ---
  # See notes below on how to handle Windsurf.
  # If config files are in ~/.config/Windsurf:
  # home.file.".config/Windsurf/settings.json".text = builtins.toJSON { /* your settings */ };

  # --- Dotfiles ---
  # Example:
  # home.file.".tmux.conf".source = ./path/to/your/.tmux.conf;
  # home.file.".config/nvim/init.vim".source = ./path/to/your/init.vim;

  # --- Environment Variables ---
  home.sessionVariables = {
    # EDITOR = "nvim";
    # UV_SYSTEM_PYTHON = "true"; # If you want uv to prefer system python for creating venvs
  };

  # Allow unfree packages if you need them (e.g. some VS Code extensions, drivers)
  # Be sure to check licenses.
  nixpkgs.config.allowUnfree = true;
}
