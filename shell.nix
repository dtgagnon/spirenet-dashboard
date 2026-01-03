{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [
    python3 # For local testing with python -m http.server
  ];

  shellHook = ''
    echo "SpireNet Website Development Environment"
    echo "Run 'python -m http.server 8000 -d site' to test locally"
  '';
}
