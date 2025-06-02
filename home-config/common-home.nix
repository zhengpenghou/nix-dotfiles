# ~/nix-dotfiles/home-config/common-home.nix
{ pkgs, config, lib, inputs, currentUser, currentSystemType, ... }:

let
  isMacOS = currentSystemType == "darwin";
  isLinux = (currentSystemType == "nixos") || (currentSystemType == "linux-standalone-hm");

  commonExtensions = with pkgs.vscode-extensions; [
    bbenoist.nix jnoortheen.nix-ide editorconfig.editorconfig eamodio.gitlens # eamodio.gitlens was corrected earlier
    ms-python.python ms-python.vscode-pylance charliermarsh.ruff
    dbaeumer.vscode-eslint esbenp.prettier-vscode
    rust-lang.rust-analyzer serayuzgur.crates
    golang.go
    github.copilot github.copilot-chat
    # Add roo-cline extension ID here
  ];

  windsurfPackages = [];

  # Define the VS Code Insiders package robustly
  vscodeInsidersPackage = pkgs.vscode.override { isInsiders = true; };

in
{
  home.stateVersion = "25.05";
  home.username = currentUser;
  home.homeDirectory = if isMacOS then "/Users/${currentUser}" else "/home/${currentUser}";

  programs.home-manager.enable = true;

  home.packages = [
    # Essentials
    pkgs.git pkgs.gnupg pkgs.htop pkgs.jq pkgs.ripgrep pkgs.fd pkgs.eza pkgs.bat pkgs.gh pkgs.kubectl
    # Development Languages & Tools
    pkgs.python311 pkgs.uv
    pkgs.nodejs_20 pkgs.pnpm
    pkgs.go
    # IDEs / Editors / Terminals (vscode-insiders is handled by programs.vscode.package)
    # pkgs.cursor # If packaged, add here
    pkgs.neovim
    pkgs.kitty
    # Neovim/LazyVim dependencies & LSPs
    pkgs.gcc
    pkgs.pyright pkgs.nodePackages.typescript-language-server pkgs.lua-language-server
    pkgs.marksman pkgs.stylua pkgs.nodePackages.prettier
    # Fonts
    pkgs.nerd-fonts.jetbrains-mono 
  ] ++ windsurfPackages;

  #programs.rustup = {
  #  enable = true;
  #  toolchains = [ "stable" "nightly" ];
  #  defaultToolchain = "stable";
  #  components = [ "rust-src" "clippy" "rustfmt" ];
  #}; # programs.rustup was previously commented out, assuming you've uncommented it or it wasn't the cause.

  programs.fish = { /* ... */ };
  programs.git = { /* ... */ };

  #programs.vscode = {
  #  enable = true;
  #  package = vscodeInsidersPackage; # This installs the specified package
  #  commandName = "code-insiders";
  #  # Updated paths for extensions and userSettings for HM 25.05+
  #  profiles.default = {
  #    extensions = commonExtensions;
  #    userSettings = {
  #      "workbench.colorTheme" = "Default Light Modern";
  #      "redhat.telemetry.enabled" = false;
  #      "github.copilot.advanced" = {};
  #      "github.copilot.chat.followUps" = "always";
  #      "github.copilot.chat.localeOverride" = "en";
  #      "github.copilot.nextEditSuggestions.enabled" = true;
  #      "github.copilot.chat.codesearch.enabled" = true;
  #      "github.copilot.chat.agent.thinkingTool" = true;
  #      "github.copilot.chat.generateTests.codeLens" = true;
  #      "github.copilot.chat.languageContext.fix.typescript.enabled" = true;
  #      "github.copilot.chat.languageContext.inline.typescript.enabled" = true;
  #      "github.copilot.chat.languageContext.typescript.enabled" = true;
  #      "github.copilot.chat.codeGeneration.useInstructionFiles" = true;
  #      "roo-cline.allowedCommands" = [ "npm test" "npm install" "tsc" "git log" "git diff" "git show" "cat" ];
  #      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
  #      "editor.formatOnSave" = true;
  #      "files.autoSave" = "afterDelay";
  #      "workbench.startupEditor" = "none";
  #      "[nix]" = { "editor.defaultFormatter" = "bbenoist.nix"; };
  #      "[python]" = { "editor.defaultFormatter" = "charliermarsh.ruff"; };
  #      "[rust]" = { "editor.defaultFormatter" = "rust-lang.rust-analyzer"; };
  #      "[typescript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
  #      "[go]" = { "editor.defaultFormatter" = "golang.go"; "editor.formatOnSave" = true; };
  #    };
  #  };
  #};

  programs.neovim = { /* ... */ };
	xdg.configFile."nvim" = {
    source = ./nvim-config; # This expects ~/nix-dotfiles/home-config/nvim-config/
    recursive = true;
  };
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14.0;
    };
    settings = lib.mkMerge [
      { # Base settings (always applied)
        # Explicitly set the shell for Kitty to use the Nix-provided Fish
        shell = "${pkgs.fish}/bin/fish"; # <--- ADD THIS LINE

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
      (lib.mkIf isMacOS {
        macos_option_as_alt = "yes";
      })
    ];
    # shellIntegration.enable = true; # This is handled by shell_integration = "enabled"; in settings now
  };

  # Font configuration for Linux (still commented out - address after major errors are gone)
  # home.fontconfig.enable = lib.mkIf isLinux true;

  home.sessionVariables = { EDITOR = "nvim"; };
  nixpkgs.config.allowUnfree = true;
}
