{ nativePkgs ? (import ./default.nix {}).pkgs,
crossBuildProject ? import ./cross-build.nix {} }:
nativePkgs.lib.mapAttrs (_: prj:
with prj.haxlbuild;
let
  executable = haxlbuild.haxlbuild.components.exes.haxlbuild;
  binOnly = prj.pkgs.runCommand "haxlbuild-bin" { } ''
    mkdir -p $out/bin
    cp ${executable}/bin/haxlbuild $out/bin
    ${nativePkgs.nukeReferences}/bin/nuke-refs $out/bin/haxlbuild
  '';
in { 
  haxlbuild-image = prj.pkgs.dockerTools.buildImage {
  name = "haxlbuild";
  tag = executable.version;
  contents = [ binOnly prj.pkgs.cacert prj.pkgs.iana-etc ];
  config.Entrypoint = "haxlbuild";
  config.Cmd = "--help";
  };
}) crossBuildProject
