# **Environment with Nix, Nix-Darwin, and Flakes**

This document outlines the setup, maintenance, and management of my macOS and Linux based machines using Nix, [Nix-Darwin](https://github.com/LnL7/nix-darwin), and [Nix Flakes](https://nixos.wiki/wiki/Flakes). This approach aims for a reproducible, robust, and customizable system. 

**Key Repository Files:**

* `flake.nix`: Defines dependencies (Nixpkgs, Nix-Darwin, Home-Manager, etc.) and outputs (Nix-Darwin system configurations, Home-Manager user configurations).  
* `flake.lock`: Pins the exact versions of all dependencies for reproducibility.  
* `system-config/`: Directory containing OS specific configurations (e.g., `system-config/moose/darwin-configuration.nix`).  
* `home-config/`: Directory containing Home-Manager configurations, with which tends to keep all my user related configurations the same across different macines.  (e.g., `home-config/common-home.nix`).
* `README.md`: This file.

## **Custom Home Directory Setup**

If your home directory is not in the standard location (e.g., `/Users/username` on macOS), you need to:

1. Set the correct home directory in your host configuration in `flake.nix`:
   ```nix
   "your-host" = {
     system = "aarch64-darwin";
     username = "yourusername";
     configModulePath = ./system-config/your-host/darwin-configuration.nix;
     type = "darwin";
     homeDirectory = "/path/to/your/home";
   };
   ```

2. Update your system configuration to use the correct home directory:
   ```nix
   users.users.${currentUser} = {
     name = currentUser;
     home = "/path/to/your/home";
     shell = pkgs.fish;
   };
   ```

3. Make sure the home directory setting in `common-home.nix` is commented out to allow the flake to override it.

This is particularly important for home-manager to work correctly with non-standard home directory paths.

## **I. Initial Installation (Focused on the setup on macOS mostly, for my linux based laptop, its been switch to NixOS)**

This setup was established by following these general steps:

1. **Install Command Line Tools (if not present):**  
   ```bash
   xcode-select --install
   ```

2. **Install Nix Package Manager:**  
   * The official multi-user installer was used:  
     ```bash
     sh <(curl -L https://nixos.org/nix/install) --daemon
     ```

   * Followed instructions to add Nix to the shell environment (e.g., sourcing `/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`).  
   * Ensured Flakes and nix-command were enabled. This might involve creating or editing `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf`) and adding:  
     ```
     experimental-features = nix-command flakes
     ```

     (Note: Newer Nix versions might enable this by default or Nix-Darwin handles it).  

### Using Determinate Systems Nix Installer

The Determinate Systems Nix installer is recommended for macOS as it provides better integration with the system:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

After installation, you may need to restart your shell or source the Nix profile:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix.sh
```

#### Integrating with nix-darwin

When using the Determinate Systems Nix installer with nix-darwin, you need to disable nix-darwin's Nix management to avoid conflicts:

```nix
# In your darwin-configuration.nix
nix.enable = false;  # Disable nix-darwin's Nix management
```

This allows the Determinate Systems installer to manage Nix itself, while nix-darwin manages the rest of your system configuration.

3. **Clone This Configuration Repository:**  
   Replace `<your-flake-repo-url>` with the actual URL and choose a local path (e.g., `~/nix-dotfiles`).  
   ```bash
   git clone <your-flake-repo-url> ~/nix-dotfiles  
   cd ~/nix-dotfiles
   ```

4. **Initial Nix-Darwin Build & Activation:**  
   * The system's hostname (e.g., moose from your prompt) should match a Nix-Darwin configuration defined in flake.nix (e.g., `darwinConfigurations.moose`).  
   * The first build applies the system configuration and, if integrated, the Home Manager configuration for the user.  
     ```bash
     nix run nix-darwin -- switch --flake .#<your-hostname>
     ```

     For example:  
     ```bash
     nix run nix-darwin -- switch --flake .#moose
     ```

   * This command might need sudo indirectly or you might need to run it as root initially depending on how Nix-Darwin sets itself up for the first time. Often, the nix run command handles this gracefully.  
5. **Shell Restart:**  
   Open a new terminal window or re-source your shell configuration for all changes (like Starship prompt, aliases, etc.) to take effect.

## **II. Regular Maintenance & Applying Changes**

1. **Edit Configuration:**  
   * Modify system settings in the relevant Nix-Darwin configuration file (e.g., `system-config/<your-hostname>/darwin-configuration.nix`).  
   * Modify user-specific settings, packages, or dotfiles in the Home Manager configuration file (`home-config/common-home.nix`).  

2. **Apply Changes:**  
   Navigate to your flake's root directory (`~/nix-dotfiles`) and run:  
   ```bash
   darwin-rebuild switch --flake .#<your-hostname>
   ```

   (Many users create an alias for this, like drs). This command will:  
   * Build the new system configuration.  
   * Build the new Home Manager generation (if it's part of the Nix-Darwin config).  
   * Activate the new configuration.  
3. **Version Control Changes:**  
   It's highly recommended to commit changes to Git:  
   ```bash
   git add .  
   git commit -m "Descriptive message of changes"  
   git push # (To your remote repository)
   ```

## **III. Updating Flake Inputs (Dependencies)**

Flake inputs (like Nixpkgs, Nix-Darwin, Home-Manager versions) are pinned in flake.lock. To update them:

1. **Update All Inputs:**  
   To update all inputs to the latest versions allowed by flake.nix:  
   ```bash
   cd ~/nix-dotfiles  
   nix flake update
   ```

   This modifies flake.lock.  
2. **Update a Specific Input:**  
   ```bash
   nix flake lock --update-input <input-name>  
   # e.g., nix flake lock --update-input nixpkgs
   ```

3. **Apply Updated Dependencies:**  
   After updating flake.lock, rebuild your system to use the new package versions:  
   ```bash
   darwin-rebuild switch --flake .#<your-hostname>
   ```

4. **Commit flake.lock:**  
   Don't forget to commit the updated flake.lock file:  
   ```bash
   git add flake.lock  
   git commit -m "Updated flake inputs"  
   git push
   ```

## **IV. Upgrading Nix Package Manager Itself**

If Nix (the package manager program) is managed declaratively by your Nix-Darwin configuration (recommended), it will be updated when you update your nixpkgs input and rebuild.

Ensure your darwin-configuration.nix (or equivalent system config file) includes a line like:

```nix
{ pkgs, ... }: {  
  nix.package = pkgs.nix; // Or pkgs.nixFlakes for a specific variant  
  // ... other configurations  
}
```

Then, after running `nix flake update` and `darwin-rebuild switch --flake .#<your-hostname>`, Nix itself will be upgraded if a newer version is available in the updated nixpkgs.

If Nix was installed manually and is *not* managed by your flake, you might need to:

* Re-run the official installer: `sh <(curl -L https://nixos.org/nix/install) --daemon`  
* Or, if you used channels for Nix itself (less common with flakes): `nix-channel --update && nix-env -iA nixpkgs.nix`

## **V. Bootstrapping on a New macOS System**

To replicate this environment on a new macOS machine:

1. **Install Command Line Tools:**  
   ```bash
   xcode-select --install
   ```

2. Install Nix Package Manager:  
   Follow step I.2.  
3. **Install Git (if not already available):**  
   You might need Git to clone your configuration. You can install it temporarily using Nix:  
   ```bash
   nix-env -iA nixpkgs.git # Installs Git into your user profile
   ```

   Alternatively, ensure Git is available from macOS Command Line Tools.  
4. **Clone This Configuration Repository:**  
   ```bash
   git clone <your-flake-repo-url> ~/nix-dotfiles  
   cd ~/nix-dotfiles
   ```

5. **Adapt Configuration (if necessary):**  
   * If the new machine has a different hostname, you might need to create a new Nix-Darwin configuration for it (e.g., `system-config/<new-hostname>/darwin-configuration.nix`) or adapt an existing one.  
   * Ensure the new hostname is referenced correctly in flake.nix.  

6. **Build & Activate:**  
   ```bash
   nix run nix-darwin -- switch --flake .#<new-hostname-or-existing-config>
   ```

7. **Restart Shell:** Open a new terminal.

## **VI. Uninstalling Everything**

Uninstalling Nix and Nix-Darwin involves removing the Nix store, configurations, and system modifications. **This is destructive and will remove all Nix-managed packages and configurations.**

1. **Remove Nix Store and Configuration:**  
   ```bash
   # Stop and remove Nix daemon services  
   sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist  
   sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist  
   # If this exists from older Nix-Darwin versions:  
   # sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist  
   # sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist

   # Remove the Nix store (THIS IS THE BIG ONE - DELETES ALL PACKAGES)  
   sudo rm -rf /nix

   # Remove Nix-related system configurations  
   sudo rm -rf /etc/nix  
   sudo rm -f /etc/profile.d/nix.sh # Or similar paths nix-darwin might have created  
   sudo rm -f /etc/bashrc.backup-before-nix # Or similar backups  
   sudo rm -f /etc/zshrc.backup-before-nix  # Or similar backups  
   # Check /etc/static for files like bashrc, zshrc that nix-darwin might create  
   # e.g., sudo rm -f /etc/static/bashrc
   ```

2. **Clean up fstab and synthetic.conf:**  
   * Edit fstab to remove the Nix volume entry if it exists:  
     ```bash
     sudo vifs
     ```
     Delete the line for `/nix`.  
   * Edit synthetic.conf to remove the Nix entry:  
     ```bash
     sudo nano /etc/synthetic.conf
     ```
     Delete the line that just says `nix`. If the file is empty or doesn't exist, you can delete it.  
3. **Remove User-Specific Nix Files:**  
   ```bash
   rm -rf ~/.nix-profile  
   rm -rf ~/.nix-defexpr  
   rm -rf ~/.nix-channels  
   rm -rf ~/.config/nix  
   rm -rf ~/.config/nixpkgs # If it's not your flake repository  
   rm -rf ~/.cache/nix  
   # Also remove your configuration clone if desired  
   # rm -rf ~/nix-dotfiles
   ```

4. **Clean Shell Configuration:**  
   Edit your shell configuration files (e.g., `~/.zshrc`, `~/.bashrc`, `~/.bash_profile`, `~/.config/fish/config.fish`) to remove any lines that source Nix or Home Manager scripts.  

5. **Reboot:**  
   A reboot is recommended to ensure all changes take effect, especially for synthetic.conf and unmounting the Nix volume.  

6. **Verify:**  
   After rebooting, check that `/nix` no longer exists and that Nix commands are not found.

This README should serve as a good starting point. You'll want to tailor the file paths and specific commands to precisely match your flake's structure and your personal aliases or workflows.