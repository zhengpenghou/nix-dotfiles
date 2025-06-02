# ~/nix-dotfiles/home-config/common-home.nix
{ pkgs, config, lib, inputs, currentUser, currentSystemType, ... }:

let
  isMacOS = currentSystemType == "darwin";
  isLinux = (currentSystemType == "nixos") || (currentSystemType == "linux-standalone-hm"); # Adjust if you add more types

  commonExtensions = with pkgs.vscode-extensions; [
    bbenoist.nix jnoortheen.nix-ide editorconfig.editorconfig gitlens.gitlens
    ms-python.python ms-python.vscode-pylance charliermarsh.ruff
    dbaeumer.vscode-eslint esbenp.prettier-vscode
    rust-lang.rust-analyzer serayuzgur.crates
    golang.go
    github.copilot github.copilot-chat # Verify actual extension IDs from VS Code Marketplace if issues
    # Add roo-cline extension ID here: e.g., somepublisher.roo-cline
  ];

  # Placeholder for Windsurf if you package it later or handle manually
  windsurfPackages = [];
    # if isLinux then [ (pkgs.callPackage ./path/to/windsurf-package.nix {}) ]
    # else if isMacOS then [ (pkgs.callPackage ./path/to/windsurf-package.nix {}) ]
    # else [];

in
{
  home.stateVersion = "25.05"; # Match Home Manager release from flake.nix
  home.username = currentUser;
  home.homeDirectory = if isMacOS then "/Users/${currentUser}" else "/home/${currentUser}";

  programs.home-manager.enable = true; # Let Home Manager manage itself

  home.packages = [
    # Essentials
    pkgs.git pkgs.gnupg pkgs.htop pkgs.jq pkgs.ripgrep pkgs.fd pkgs.eza pkgs.bat pkgs.gh pkgs.kubectl

    # Development Languages & Tools
    pkgs.python311 # Or your preferred Python version
    pkgs.uv
    pkgs.nodejs_20 # Provides npm. Or your preferred Node.js version
    pkgs.pnpm
    pkgs.go

    # IDEs / Editors / Terminals
    pkgs.vscode-insiders # For programs.vscode to use
    # pkgs.cursor # If packaged, add here
    pkgs.neovim  # For programs.neovim and LazyVim
    pkgs.kitty   # For programs.kitty

    # Neovim/LazyVim dependencies & LSPs
    pkgs.gcc     # For TreeSitter, etc.
    pkgs.pyright
    pkgs.nodePackages.typescript-language-server
    pkgs.lua-language-server # For Lua in Neovim config
    pkgs.marksman # Markdown LSP
    pkgs.stylua   # Lua formatter
    pkgs.nodePackages.prettier # JS/TS/JSON/MD formatter

    # Fonts (example for Kitty & terminal UI)
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

  ] ++ windsurfPackages;

  programs.rustup = {
    enable = true;
    toolchains = [ "stable" "nightly" ]; # Space separated
    defaultToolchain = "stable";
    components = [ "rust-src" "clippy" "rustfmt" ];
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -x EDITOR nvim
      alias ls='eza --git --icons --color=always' # Added --color=always for consistency
      alias cat='bat --paging=never' # Added --paging=never for direct output
      # You can add more aliases or functions here
    '';
  };

  programs.git = {
    enable = true;
    userName = "Zhengpeng Hou"; # Your Name
    userEmail = "zhengpeng.hou@gmail.com"; # Your Email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      "alias.st" = "status -sb";
      "alias.co" = "checkout";
      "alias.br" = "branch";
      "alias.ci" = "commit";
    };
    signing = {
      key = "FF5180A308BCE444BDA6FA4D49E1ED6DE3D83CCB"; # Key as a string
      signByDefault = true;
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-insiders; # Ensure this is the package you want to configure
    extensions = commonExtensions;
    userSettings = {
      "workbench.colorTheme" = "Default Light Modern";
      "redhat.telemetry.enabled" = false;
      "github.copilot.advanced" = {};
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
      "roo-cline.allowedCommands" = [ "npm test" "npm install" "tsc" "git log" "git diff" "git show" "cat" ];
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'"; # Ensure font name matches installed one
      "editor.formatOnSave" = true;
      "files.autoSave" = "afterDelay";
      "workbench.startupEditor" = "none";
      "[nix]" = { "editor.defaultFormatter" = "bbenoist.nix"; }; # or jnoortheen.nix-ide
      "[python]" = { "editor.defaultFormatter" = "charliermarsh.ruff"; };
      "[rust]" = { "editor.defaultFormatter" = "rust-lang.rust-analyzer"; };
      "[typescript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "[go]" = { "editor.defaultFormatter" = "golang.go"; "editor.formatOnSave" = true; };
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    withPython3 = true;
    withNodeJs = true;
    defaultEditor = true; # Sets Neovim as $EDITOR and $VISUAL
  };

  # Link your LazyVim configuration (assumes it's in ./nvim-config relative to this file)
  xdg.configFile."nvim" = {
    source = ./nvim-config; # This expects ~/nix-dotfiles/home-config/nvim-config/
    recursive = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font"; # Ensure this matches the font installed by nerdfonts
      size = 12.0;
    };
    settings = {
      background = "#282A36"; # Example: Dracula-like background
      foreground = "#F8F8F2";
      cursor     = "#F8F8F2";
      confirm_os_window_close = 0;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      remember_window_size = "yes"; # Persist window size
      initial_window_width = "100c";  # Initial window width in character cells
      initial_window_height = "40c"; # Initial window height in character cells
    };
    shellIntegration.enable = true; # Enable shell integration (recommended)
    macosOptionAsAlt = lib.mkIf isMacOS true; # Map Option key to Alt on macOS
  };

  # Enable font discovery for Home Manager managed fonts, especially on Linux
  #home.fonts.fontProfiles = lib.mkIf isLinux {
  #  enable = true;
  #};
  # home.fontconfig.enable = lib.mkIf isLinux true;


  home.sessionVariables = {
    EDITOR = "nvim";
    # UV_SYSTEM_PYTHON = "true"; # If you want uv to prefer system python when creating venvs initially
  };

  # Allow unfree packages (e.g., for some VS Code extensions like Copilot, Pylance)
  nixpkgs.config.allowUnfree = true;
}
