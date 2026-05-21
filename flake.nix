{
  description = "Pi Coding Agent - fork with parallel extension loading";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          pi = pkgs.nodejs.pkgs.pi-coding-agent;
          default = self.packages.${system}.pi;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_24
            bun
            git
            jq
            # Nix darwin specific
            darwin.system_cmds
          ];

          shellHook = ''
            echo "Pi Development Environment (Nix Darwin)"
            echo "Node: $(node --version)"
            echo "Bun: $(bun --version)"
            echo ""
            echo "Available commands:"
            echo "  npm ci           - Install dependencies"
            echo "  npm run build    - Build Pi"
            echo "  npm test         - Run tests"
            echo "  pi --version     - Show Pi version"
            echo "  pi --help        - Show Pi help"
          '';
        };

        # Allow building Pi locally
        packages.pi-local = pkgs.buildNpmPackage {
          name = "pi-coding-agent";
          version = "0.75.4";
          src = ./packages/coding-agent;
          npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          postInstall = ''
            mkdir -p $out/bin
            cp -r dist/* $out/lib/node_modules/pi-coding-agent/
            ln -s $out/lib/node_modules/pi-coding-agent/cli.js $out/bin/pi
            chmod +x $out/bin/pi
          '';
        };
      }
    );
}
