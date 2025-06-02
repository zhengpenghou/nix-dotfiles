# ~/nix-dotfiles/system-config/moose/darwin-configuration.nix
{ config, pkgs, lib, inputs, currentUser, currentSystemType, ... }: # currentUser will be "zhengpenghou"
{
  # List macOS system packages if any (most user apps go in common-home.nix)
  environment.systemPackages = with pkgs; [
    # coreutils # Example: if you want Nix coreutils available system-wide
  ];

  # Auto upgrade nix package and nix binary wrappers.
  services.nix-daemon.enable = true; # Managed by nix-darwin installer usually
  nix.package = pkgs.nix; # Ensure Nix itself is managed by Nix

  # Enable Flakes and the new Nix command system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@admin" currentUser ]; # Allow admin group and current user to use restricted features

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true; # Even if you use fish, some scripts might expect bash
  programs.fish.enable = true; # Enable fish shell globally if desired

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.revShort or "dirty";

  # This is crucial for nix-darwin. Check their documentation for the latest recommended version.
  system.stateVersion = 6;

  # Define the user account at the system level.
  # Home Manager will then configure this user's environment.
  users.users.${currentUser} = {
    name = currentUser;
    home = "/Users/${currentUser}";
    shell = pkgs.fish; # Set the default login shell for this user
  };

  # Example macOS specific system settings:
  # system.keyboard.remapCapsLockToControl = true;
  services.ssh.enable = true; # Enable OpenSSH server
  security.pam.enableSudoTouchIdAuth = true; # Enable Touch ID for sudo

  # Allow unfree packages system-wide if needed for system packages or services
  nixpkgs.config.allowUnfree = true;

  # Ensure fonts from Home Manager are discoverable by system applications
  fonts.fontDir.enable = true;
}
