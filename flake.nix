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
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Add any tools needed for development
              python3  # For local testing with python -m http.server
            ];

            shellHook = ''
              echo "SpireNet Website Development Environment"
              echo "Run 'python -m http.server 8000 -d site' to test locally"
            '';
          };
        }
      );

      # Formatter for Nix files
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );
    };
}
