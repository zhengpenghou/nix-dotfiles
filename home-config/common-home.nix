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
    pkgs.roboto-mono
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
      name = "Roboto Mono"; # From your new config
      package = pkgs.roboto-mono; # Ensures this font is available
      size = 15;
    };

    settings = lib.mkMerge [
      { # Base settings merged from your new config and previous template
        # From your new settings block & extraConfig:
        shell = "${pkgs.fish}/bin/fish";
        allow_remote_control = true; # Was also in extraConfig, prefer typed setting
        window_padding_width = 15;   # Was also in extraConfig
        enable_audio_bell = false;   # Was also in extraConfig as 'no'
        copy_on_select = "yes";
        macos_thicken_font = 0.25; # Moved from extraConfig
        listen_on = "unix:/tmp/mykitty"; # Moved from extraConfig
        hide_window_decorations = "titlebar-only"; # Moved from extraConfig
        placement_strategy = "top-left"; # Moved from extraConfig
        mouse_hide_wait = 3.0; # Moved from extraConfig
        scrollback_pager_history_size = 4000; # Moved from extraConfig
        repaint_delay = 10; # Moved from extraConfig
        input_delay = 3; # Moved from extraConfig
        sync_to_monitor = "yes"; # Moved from extraConfig
        window_border_width = "1pt"; # Moved from extraConfig
        active_border_color = "#41413d"; # Moved from extraConfig
        inactive_border_color = "#1F1F2A"; # Moved from extraConfig
        confirm_os_window_close = -1; # Moved from extraConfig (use number for -1)
        shell_integration = "no-cursor"; # From your extraConfig, overrides previous "enabled"
        cursor_shape = "beam"; # Moved from extraConfig

        # Tab bar settings from your extraConfig (and some from previous template)
        tab_bar_edge = "bottom";
        tab_bar_style = "separator";
        tab_separator = "";
        tab_title_template = "  {title}  ";
        active_tab_font_style = "normal"; # Moved from extraConfig

        # Colors from your extraConfig
        background = "#0D1014";
        foreground = "#DCD7BA";
        selection_background = "#2D4F67";
        selection_foreground = "#C8C093";
        url_color = "#72A7BC";
        cursor = "#C8C093"; # This will override the one from my previous template
        active_tab_background = "#16161D";
        active_tab_foreground = "#DCD7BA";
        inactive_tab_foreground = "#727169";
        inactive_tab_background = "#0D1014";
        color0 = "#090618";
        color1 = "#C34043";
        color2 = "#76946A";
        color3 = "#C0A36E";
        color4 = "#7E9CD8";
        color5 = "#957FB8";
        color6 = "#6A9589";
        color7 = "#C8C093";
        color8 = "#727169";
        color9 = "#E82424";
        color10 = "#98BB6C";
        color11 = "#E6C384";
        color12 = "#7FB4CA";
        color13 = "#938AA9";
        color14 = "#7AA89F";
        color15 = "#DCD7BA";
        color16 = "#FFA066";
        color17 = "#FF5D62";

        # Retained from previous template (important)
        update_check_interval = 0; # Keep this if you want to disable Kitty's own checks
        remember_window_size = "yes";
        initial_window_width = "100c";
        initial_window_height = "40c";
      }
      # Conditionally add macOS-specific settings
      (lib.mkIf isMacOS {
        macos_option_as_alt = "yes"; # From your extraConfig, handled conditionally here
      })
    ];

    extraConfig = ''
      # Settings that are complex, multi-line, or not easily typed,
      # or that you prefer to keep as raw kitty.conf lines.
      # Duplicates from settings above have been removed.

      # Font fallbacks - these font_family lines might be needed if the main font block
      # doesn't handle variants perfectly, or if Roboto Mono doesn't have bold/italic shapes
      # that Kitty picks up. For now, assuming the `font` block is primary.
      # If you find bold/italic not working, you can uncomment these.
      # font_family         Roboto Mono Regular
      # bold_font           Roboto Mono Bold
      # italic_font         Roboto Mono Italic
      # bold_italic_font    Roboto Mono Bold Italic

      symbol_map U+ea60-U+ebd1 codicon # From your extraConfig

      # Symbol Nerd Font mappings from your extraConfig
      symbol_map U+E5FA-U+E62B Symbols Nerd Font
      symbol_map U+E700-U+E7C5 Symbols Nerd Font
      symbol_map U+F000-U+F2E0 Symbols Nerd Font
      symbol_map U+E200-U+E2A9 Symbols Nerd Font
      symbol_map U+F500-U+FD46 Symbols Nerd Font
      symbol_map U+E300-U+E3EB Symbols Nerd Font
      symbol_map U+F400-U+F4A8,U+2665,U+26A1,U+F27C Symbols Nerd Font
      symbol_map U+E0A3,U+E0B4-U+E0C8,U+E0CC-U+E0D2,U+E0D4 Symbols Nerd Font
      symbol_map U+23FB-U+23FE,U+2b58 Symbols Nerd Font
      symbol_map U+F300-U+F313 Symbols Nerd Font
      symbol_map U+E000-U+E00D Symbols Nerd Font

      mouse_map left click ungrabbed mouse_click_url_or_select

      map alt+3 send_text all #

      enabled_layouts splits:split_axis=horizontal

      map ctrl+shift+r combine : clear_terminal active : send_text normal \x0c

      map alt+h  kitten pass_keys.py neighboring_window left alt+h
      map alt+l  kitten pass_keys.py neighboring_window right alt+l
      map alt+k  kitten pass_keys.py neighboring_window top alt+k
      map alt+j  kitten pass_keys.py neighboring_window bottom alt+j

      map cmd+t new_tab_with_cwd
    '';
  };

  # Font configuration for Linux (still commented out - address after major errors are gone)
  # home.fontconfig.enable = lib.mkIf isLinux true;

  home.sessionVariables = { EDITOR = "nvim"; };
  nixpkgs.config.allowUnfree = true;
}
