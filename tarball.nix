{ nativePkgs ? (import ./default.nix {}).pkgs,
crossBuildProject ? import ./cross-build.nix {} }:
nativePkgs.lib.mapAttrs (_: prj:
with prj.haxlbuild;
let
  executable = haxlbuild.haxlbuild.components.exes.haxlbuild;
  binOnly = prj.pkgs.runCommand "haxlbuild-bin" { } ''
    mkdir -p $out/bin
    cp -R ${executable}/bin/* $out/bin/
    ${nativePkgs.nukeReferences}/bin/nuke-refs $out/bin/haxlbuild
  '';

  tarball = nativePkgs.stdenv.mkDerivation {
    name = "haxlbuild-tarball";
    buildInputs = with nativePkgs; [ zip ];

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/
      zip -r -9 $out/haxlbuild-tarball.zip ${binOnly}
    '';
  };
in {
 haxlbuild-tarball = tarball;
}
) crossBuildProject
