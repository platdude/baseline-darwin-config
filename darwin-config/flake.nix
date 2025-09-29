{
  description = "nix-darwin base configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/?rev=b5d84e5b26d74be4bd806161af0878251342c65a";
    nix-darwin.url = "github:lnl7/nix-darwin/?rev=1fef4404de4d1596aa5ab2bd68078370e1b9dcdb";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    determinatenix.url = "github:DeterminateSystems/nix/v2.27.1";
    determinatenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      determinatenix,
      ...
    }:
    let
      nixversion = "2_27";
      # This the baseline configuration for nix-darwin
      darwinConfig =
        { pkgs, ... }:
        {
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
            aws-vault

            # Nix
            nixfmt-rfc-style
            nixfmt-tree
            nixd

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
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # Configure dock
          system.defaults.dock.autohide = true;
          system.defaults.dock.show-recents = false;

          # Set homebrew-installed application to not be installed in /usr/local/bin
          homebrew.enable = true;
          homebrew.onActivation.cleanup = "uninstall";

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
      # Outputs for reuse in other flakes
      darwinConfig = darwinConfig;
      nixDarwin = nix-darwin;
      pkgs = nixpkgs;
      determinatenix = determinatenix;
    };
}
