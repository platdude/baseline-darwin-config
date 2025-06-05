{
  description = "nix-darwin base configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    determinatenix.url = "https://flakehub.com/f/DeterminateSystems/nix/2.27.*";
    determinatenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self
    , nix-darwin
    , nixpkgs
    , home-manager
    , nix-vscode-extensions
    , determinatenix
    , ...
    }:
    let
      system = "x86_64-darwin";
      nixversion = "2_27";

      pkgs = import nixpkgs
        {
          # We use the system architecture variable
          inherit system;

          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };

          # We make vscode-extensions available in the package set
          overlays = [ nix-vscode-extensions.overlays.default ];

          # And we extend pkgs with a set merge operator
        } // {
        nix = determinatenix.packages.${system}.default;
      };

      # This the baseline configuration for nix-darwin
      darwinConfig = { system, pkgs, ... }: {

        # These are command line tools that are installed globally on all hosts.
        environment.systemPackages = with pkgs; [
          # Dev
          cloc
          git
          gitAndTools.git-absorb
          git-crypt
          difftastic
          pre-commit
          gnupg
          awscli2

          # Nix
          hydra-check
          nixpkgs-fmt
          nixfmt-classic
          nixd
          nil

          # OS Essentials
          fd
          htop
          neovim
          nmap
          ripgrep
          tmux
          tree
          vim
          openssl

          # MasApp
          mas

          # Tools
          iperf
          jq
          tldr
          yq
        ];

        # To get completion for system packages (e.g. systemd).
        environment.pathsToLink = [ "/share/zsh" ];

        # Stores metadata about the current configuration revision in the Nix store.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Nix-determinate manages the Nix installation and configuration.
        nix.enable = false;
        # Auto upgrade nix package and the daemon service.
        nix.package = pkgs.${nixversion};

        # This enables flakes support as well as making extra nix commands available.
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # Configure dock
        system.defaults.dock.autohide = true;
        system.defaults.dock.show-recents = false;

        # Set homebrew-installed application to not be installed in /usr/local/bin
        homebrew.enable = true;
        homebrew.onActivation.cleanup = "uninstall";

        # Only install magnet if it's my personal laptop
        #homebrew.masApps = if system != "aarch64-darwin" then { magnet = 441258766; } else { };

        # Declare the user that will be running `nix-darwin`.
        users.users.alberto = {
          name = "alberto";
          home = "/Users/alberto";
        };

        # Global casks
        homebrew = {
          casks = [
            # Console
            "iterm2"

            # Browsers
            "firefox"
            "google-chrome"

            # Drivers etc.
            "logitech-options"

            # Media
            "spotify"
            "vlc"

            # Office
            "notion"

            # Tools
            "appcleaner"
            "bitwarden"

            # apple default fonts
            "font-sf-pro"
          ];
        };
      };
    in
    {
      baseline = {
        darwinConfig = darwinConfig;
        pkgs = pkgs;
      };
    };
}
