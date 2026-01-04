{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
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
}
