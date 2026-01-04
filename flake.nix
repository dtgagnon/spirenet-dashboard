{
  description = "SpireNet service directory website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            name = "spirenet-link";
            src = ./site;

            installPhase = ''
              mkdir -p $out
              cp -r * $out/
            '';

            meta = {
              description = "SpireNet service directory landing page";
              license = pkgs.lib.licenses.mit;
              maintainers = [ "dtgagnon" ];
            };
          };
        }
      );

      # Development shell for local testing
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = import ./shell.nix { inherit pkgs; };
        }
      );

      # Formatter for Nix files
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );

      # NixOS module
      nixosModules.default = { config, lib, pkgs, ... }: {
        imports = [ ./module.nix ];
        config = lib.mkIf config.services.spirenet-dashboard.enable {
          services.spirenet-dashboard.package = lib.mkDefault self.packages.${pkgs.system}.default;
        };
      };
    };
}
