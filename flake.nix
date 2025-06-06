# ~/nix-dotfiles/flake.nix
{
  description = "Unified Configuration for All My Machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # my-lazyvim-config = { url = "github:your_github_username/your-lazyvim-config-repo"; flake = false; };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
    let
      hosts = {
        "moose" = {
          system = "aarch64-darwin";
          username = "zhengpenghou";
          configModulePath = ./system-config/moose/darwin-configuration.nix;
          type = "darwin";
        };
        "fiesty" = {
          system = "x86_64-darwin";
          username = "zp";
          configModulePath = ./system-config/fiesty/darwin-configuration.nix;
          type = "darwin";
        };
        # "nano" = {
        #   system = "x86_64-linux";
        #   username = "zp";
        #   configModulePath = ./system-config/nano/configuration.nix;
        #   type = "nixos";
        # };
        # ... other hosts ...
      };

      mkSpecialArgs = hostEntry: { # These args are for modules loaded by home-manager or system configs
        inherit inputs;
        currentUser = hostEntry.username;
        currentSystemType = hostEntry.type;
      };

    in
    {
      # --- Standalone Home Manager Configurations ---
      homeConfigurations = nixpkgs.lib.mapAttrs'
        (hostname: hostEntry: nixpkgs.lib.nameValuePair "${hostEntry.username}@${hostname}" (
          home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = hostEntry.system;
              config.allowUnfree = true;
            };
            extraSpecialArgs = mkSpecialArgs hostEntry;
            modules = [
              ./home-config/common-home.nix
            ];
          }
        ))
        hosts;

      # --- macOS System Configurations (using nix-darwin) ---
      darwinConfigurations = nixpkgs.lib.mapAttrs'
        (hostname: hostEntry: nixpkgs.lib.nameValuePair hostname (
          nix-darwin.lib.darwinSystem {
            system = hostEntry.system;
            # These specialArgs are for nix-darwin modules (like your darwin-configuration.nix)
            specialArgs = mkSpecialArgs hostEntry;
            modules = [
              hostEntry.configModulePath
              home-manager.darwinModules.home-manager # Import the Home Manager darwin module
              { # Configure Home Manager within this system build
                # These extraSpecialArgs are passed to Home Manager modules (like common-home.nix)
                home-manager.extraSpecialArgs = mkSpecialArgs hostEntry;
                home-manager.users.${hostEntry.username} = {
                  imports = [ ./home-config/common-home.nix ];
                  # Optional: If common-home.nix doesn't set username/home based on currentUser,
                  # you can set them explicitly here:
                  # home.username = hostEntry.username;
                  # home.homeDirectory = "/Users/${hostEntry.username}";
                };
              home-manager.backupFileExtension = "hm-backup";
              }
            ];
          }
        ))
        (nixpkgs.lib.filterAttrs (hostname: hostEntry: hostEntry.type == "darwin") hosts);

      # --- NixOS System Configurations ---
      nixosConfigurations = nixpkgs.lib.mapAttrs'
        (hostname: hostEntry: nixpkgs.lib.nameValuePair hostname (
          nixpkgs.lib.nixosSystem {
            system = hostEntry.system;
            # These specialArgs are for NixOS modules (like your configuration.nix)
            specialArgs = mkSpecialArgs hostEntry;
            modules = [
              hostEntry.configModulePath
              home-manager.nixosModules.home-manager # Import the Home Manager NixOS module
              { # Configure Home Manager within this system build
                # These extraSpecialArgs are passed to Home Manager modules (like common-home.nix)
                home-manager.extraSpecialArgs = mkSpecialArgs hostEntry;
                home-manager.users.${hostEntry.username} = {
                  imports = [ ./home-config/common-home.nix ];
                  # Optional:
                  # home.username = hostEntry.username;
                  # home.homeDirectory = "/home/${hostEntry.username}";
                };
              home-manager.backupFileExtension = "hm-backup";
              }
            ];
          }
        ))
        (nixpkgs.lib.filterAttrs (hostname: hostEntry: hostEntry.type == "nixos") hosts);

      # --- Standalone Home Manager Configurations (Example) ---
      # homeConfigurations = nixpkgs.lib.mapAttrs'
      #   (hostname: hostEntry: nixpkgs.lib.nameValuePair "${hostEntry.username}@${hostname}" (
      #     home-manager.lib.homeManagerConfiguration {
      #       pkgs = nixpkgs.legacyPackages.${hostEntry.system};
      #       # For standalone Home Manager, extraSpecialArgs is defined directly here
      #       extraSpecialArgs = mkSpecialArgs hostEntry;
      #       modules = [
      #         hostEntry.configModulePath # This would be a home.nix file that imports common-home.nix
      #                                    # and also sets home.username, home.homeDirectory, home.stateVersion.
      #       ];
      #     }
      #   ))
      #   (nixpkgs.lib.filterAttrs (hostname: hostEntry: hostEntry.type == "home-manager") hosts);
    };
}
