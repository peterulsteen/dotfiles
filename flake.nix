{
  description = "Cross-platform (Linux and macOS) CLI toolbelt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = { self, nixpkgs, ghostty, ... }:
  let
    systems = [
      "x86_64-linux" "aarch64-linux"
      "x86_64-darwin" "aarch64-darwin"
    ];

    gen = nixpkgs.lib.genAttrs systems (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Ghostty package attr can be `ghostty` or `default` depending on upstream.
        ghosttyPkg =
          (ghostty.packages.${system}.ghostty or ghostty.packages.${system}.default);

        # Core stack
        common = with pkgs; [
          # shells & prompt
          fish
          starship
	        zoxide

          # editor & multiplexers
          neovim
          tmux
          zellij

          # find/fzf/git TUI
          fzf
          fd
          ripgrep
          bat
          eza
          lazygit
          gh

          # net & sys
          curl
          wget
          unzip
          lsof
          socat
          nmap
          iftop
          iotop
          btop
          fastfetch
          jq
          yq-go

          # cloud/dev
          awscli2
          aws-vault
          duckdb

          # extras
          tealdeer
          tree
          devbox
          mise
          just
          direnv
        ];

        linuxOnly  = with pkgs; [ xclip ];
        darwinOnly = [ ];
      in
      {
        # Single bundle installable via nix profile
        toolbelt = pkgs.buildEnv {
          name  = "toolbelt";
          paths = common ++ (if pkgs.stdenv.isLinux then linuxOnly else darwinOnly);
        };

        # Also expose Ghostty via this flake for convenience
        ghostty = ghosttyPkg;

        # Make `nix profile install github:<you>/toolbelt` work
        default = self.packages.${system}.toolbelt;
      }
    );
  in
  {
    packages = gen;

    # Convenience launchers (optional)
    apps = nixpkgs.lib.genAttrs systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        ghosttyPkg =
          (ghostty.packages.${system}.ghostty or ghostty.packages.${system}.default);
      in
      {
        nvim = { type = "app"; program = "${pkgs.neovim}/bin/nvim"; };
        ghostty = { type = "app"; program = "${ghosttyPkg}/bin/ghostty"; };
      }
    );
  };
}

