{
  description = "My Cross-Platform Home and System Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Or your preferred nixpkgs branch
    home-manager = {
      url = "github:nixos/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensures HM uses the same nixpkgs
    };
    # Optional: For dev shells, if you manage projects with flakes too
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # --- Define your users and systems ---
      macUser = "zhengpenghou"; # Replace
      macSystem = "aarch64-darwin";  # Or "aarch64-darwin" for Apple Silicon

      thinkpadUser = "nano"; # Replace
      thinkpadHostname = "nano"; # Replace with your ThinkPad's hostname for NixOS config
      thinkpadSystem = "x86_64-linux";

      # Special arguments to pass to Home Manager modules
      # This allows home.nix to know about the user and system context
      commonSpecialArgs = { inherit inputs; };

    in
    {
      # --- macOS Home Manager Configuration (Standalone) ---
      homeConfigurations."${macUser}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${macSystem};
        extraSpecialArgs = commonSpecialArgs // { currentUser = macUser; currentSystem = macSystem; };
        modules = [
          ./home-config/common-home.nix
          # You can add a macos-specific home-manager file here if needed:
          # ./home-config/macos-home.nix
        ];
      };

      # --- NixOS System Configuration (ThinkPad X1 Nano) ---
      nixosConfigurations."${thinkpadHostname}" = nixpkgs.lib.nixosSystem {
        system = thinkpadSystem;
        specialArgs = commonSpecialArgs // { currentUser = thinkpadUser; currentSystem = thinkpadSystem; }; # Pass to NixOS modules
        modules = [
          ./system-config/thinkpad/configuration.nix # Main NixOS config for ThinkPad
          home-manager.nixosModules.home-manager # Integrate Home Manager
          {
            # Configure Home Manager for the specific user on NixOS
            home-manager.users.${thinkpadUser} = {
              imports = [
                ./home-config/common-home.nix
                # You can add a linux-specific home-manager file here if needed:
                # ./home-config/linux-home.nix
              ];
              # Optionally set username and home dir here if not derived or set in common-home.nix
              # home.username = thinkpadUser;
              # home.homeDirectory = "/home/${thinkpadUser}";
            };
          }
        ];
      };
    };
}
