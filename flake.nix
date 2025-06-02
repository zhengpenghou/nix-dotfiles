# ~/nix-dotfiles/flake.nix
{
  description = "Unified Configuration for All My Machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # my-lazyvim-config = { url = "github:yourusername/your-lazyvim-config-repo"; flake = false; };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
    let
      # --- Define your machines and their specific users ---
      # You can add all your machines here.
      # The 'hostnameInFlake' is what you'll use in commands like `darwin-rebuild switch --flake .#moose`
      # The 'username' is the actual username on that system.
      # The 'configModulePath' points to its system-level configuration file.
      hosts = {
        "moose" = { # MacBook Pro
          system = "aarch64-darwin"; # Verify: aarch64 for Apple Silicon, x86_64 for Intel
          username = "zhengpenghou";
          configModulePath = ./system-config/moose/darwin-configuration.nix;
          type = "darwin";
        };
        "fiesty" = { # Mac mini
          system = "x86_64-darwin";  # Verify: aarch64 for Apple Silicon, x86_64 for Intel
          username = "zp";
          configModulePath = ./system-config/fiesty/darwin-configuration.nix;
          type = "darwin";
        };
        "nano" = { # X1 Nano Linux Laptop (NixOS)
          system = "x86_64-linux";
          username = "zp";
          configModulePath = ./system-config/nano/configuration.nix;
          type = "nixos";
        };
        # Example for a Linux server (NixOS)
        # "server1" = {
        #   system = "x86_64-linux";
        #   username = "zp"; # Assuming 'zp' for servers too
        #   configModulePath = ./system-config/server1/configuration.nix;
        #   type = "nixos";
        # };
        # Example for another Linux laptop (non-NixOS, using standalone Home Manager)
        # "otherlinuxlaptop" = {
        #   system = "x86_64-linux";
        #   username = "zp";
        #   # For standalone HM, the "module" is the primary home.nix that imports common-home.nix
        #   # and sets username/homeDirectory directly.
        #   configModulePath = ./home-config/otherlinuxlaptop-standalone-home.nix;
        #   type = "home-manager";
        # };
      };

      # --- Helper to create specialArgs for modules ---
      mkSpecialArgs = hostEntry: {
        inherit inputs;
        currentUser = hostEntry.username; # Pass the host-specific username
        currentSystemType = hostEntry.type;
      };

      # --- Helper to build Home Manager user modules ---
      # This ensures common-home.nix is always imported.
      # You can add machine-type specific HM modules here too (e.g., macos-home.nix, linux-home.nix)
      mkHomeManagerUserModules = hostEntry: {
        home-manager.users.${hostEntry.username} = {
          imports = [ ./home-config/common-home.nix ]
          # Example for OS-specific HM additions:
          # ++ (lib.optional (hostEntry.type == "darwin") ./home-config/macos-home.nix)
          # ++ (lib.optional (hostEntry.type == "nixos" || hostEntry.type == "home-manager") ./home-config/linux-home.nix)
          ;
        };
      };

    in
    {
      # --- macOS System Configurations (using nix-darwin) ---
      darwinConfigurations = nixpkgs.lib.mapAttrs'
        (hostname: hostEntry: nixpkgs.lib.nameValuePair hostname (
          nix-darwin.lib.darwinSystem {
            system = hostEntry.system;
            specialArgs = mkSpecialArgs hostEntry;
            modules = [
              hostEntry.configModulePath
              home-manager.darwinModules.home-manager
              (mkHomeManagerUserModules hostEntry) # Use the helper
            ];
          }
        ))
        (nixpkgs.lib.filterAttrs (hostname: hostEntry: hostEntry.type == "darwin") hosts);

      # --- NixOS System Configurations ---
      nixosConfigurations = nixpkgs.lib.mapAttrs'
        (hostname: hostEntry: nixpkgs.lib.nameValuePair hostname (
          nixpkgs.lib.nixosSystem {
            system = hostEntry.system;
            specialArgs = mkSpecialArgs hostEntry;
            modules = [
              hostEntry.configModulePath
              home-manager.nixosModules.home-manager
              (mkHomeManagerUserModules hostEntry) # Use the helper
            ];
          }
        ))
        (nixpkgs.lib.filterAttrs (hostname: hostEntry: hostEntry.type == "nixos") hosts);

      # --- Standalone Home Manager Configurations (for non-NixOS Linux) ---
      # homeConfigurations = nixpkgs.lib.mapAttrs'
      #   (hostname: hostEntry: nixpkgs.lib.nameValuePair "${hostEntry.username}@${hostname}" ( # e.g. zp@otherlinuxlaptop
      #     home-manager.lib.homeManagerConfiguration {
      #       pkgs = nixpkgs.legacyPackages.${hostEntry.system};
      #       extraSpecialArgs = mkSpecialArgs hostEntry; # Passes currentUser
      #       modules = [
      #         hostEntry.configModulePath # This would be a home.nix file setting username & importing common-home.nix
      #       ];
      #     }
      #   ))
      #   (nixpkgs.lib.filterAttrs (hostname: hostEntry: hostEntry.type == "home-manager") hosts);
    };
}
