# ~/nix-dotfiles/system-config/moose/darwin-configuration.nix
{ config, pkgs, lib, inputs, currentUser, currentSystemType, ... }: # currentUser will be "zhengpenghou"
{
  # List macOS system packages if any (most user apps go in common-home.nix)
  environment.systemPackages = with pkgs; [
    # coreutils # Example: if you want Nix coreutils available system-wide
  ];

  # nix-darwin manages the nix-daemon when nix.enable is true (implied by nix.package).
  # So, services.nix-daemon.enable is not needed.
  nix.package = pkgs.nix; # Ensure Nix itself is managed by Nix
  nix.enable = true; # Explicitly enable Nix, ensures daemon is managed

  # Enable Flakes and the new Nix command system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@admin" currentUser ]; # Allow admin group and current user to use restricted features
  # You might want to add other nix.settings here, for example:
  # nix.settings.build-users-group = "nixbld";

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true; # Even if you use fish, some scripts might expect bash
  programs.fish.enable = true; # Enable fish shell globally if desired

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.revShort or "dirty";

  # This is crucial for nix-darwin. Use the version recommended by nix-darwin.
  # You mentioned it defaulted to 6 from its output.
  system.stateVersion = 6;

  # Define the user account at the system level.
  # Home Manager will then configure this user's environment.
  users.users.${currentUser} = {
    name = currentUser;
    home = "/Users/${currentUser}";
    shell = pkgs.fish; # System default login shell for the user
  };

  # Example macOS specific system settings:
  # system.keyboard.remapCapsLockToControl = true;

  # Enable OpenSSH server
  services.openssh.enable = true;
  # services.openssh.permitRootLogin = "no"; # Example further sshd config

  # Enable Touch ID for sudo (using the new option name)
  security.pam.services.sudo_local.touchIdAuth = true; # Corrected option name

  # Allow unfree packages system-wide if needed for system packages or services
  nixpkgs.config.allowUnfree = true;

  # fonts.fontDir.enable is no longer needed or effective.
  # Fonts installed by Home Manager (e.g., to ~/.nix-profile/share/fonts or ~/Library/Fonts)
  # or system-wide (to /Library/Fonts) should be picked up automatically by macOS.
}
