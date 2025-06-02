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
      alias ls='eza --git --icons --color=always'
      alias cat='bat --paging=never'
      # You can add more aliases or functions here
    '';
  };

  programs.git = {
    enable = true;
    userName = "Zhengpeng Hou";
    userEmail = "zhengpeng.hou@gmail.com";
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
    package = pkgs.vscode-insiders;
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

  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    withPython3 = true;
    withNodeJs = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim" = {
    source = ./nvim-config; # Expects ~/nix-dotfiles/home-config/nvim-config/
    recursive = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12.0;
    };
    settings = lib.mkMerge [ # Use mkMerge for combining base and conditional settings
      { # Base settings (always applied)
        background = "#282A36";
        foreground = "#F8F8F2";
        cursor     = "#F8F8F2";
        confirm_os_window_close = 0;
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        remember_window_size = "yes";
        initial_window_width = "100c";
        initial_window_height = "40c";
        shell_integration = "enabled";
      }
      # Conditionally add macOS-specific settings
      (lib.mkIf isMacOS {
        macos_option_as_alt = "yes"; # This is the kitty.conf option name
      })
    ];
    # shellIntegration.enable = true;
    # Removed top-level macosOptionAsAlt as it's now in settings
  };

  # Font configuration for Linux (currently commented out for macOS build testing)
  # If you uncomment this later for Linux, and it still causes issues on macOS builds,
  # it might indicate a deeper evaluation problem or version incompatibility.
  # home.fontconfig.enable = lib.mkIf isLinux true;

  home.sessionVariables = {
    EDITOR = "nvim";
    # UV_SYSTEM_PYTHON = "true";
  };

  nixpkgs.config.allowUnfree = true;
}
