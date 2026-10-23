{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "gnome-rounded-blur";
  version = "1.0.2-unstable-2026-10-21";
  src = pkgs.fetchFromGitHub {
    owner = "kancko";
    repo = "gnome-rounded-blur";
    rev = "d0e6aa6ce945f548c4f54e9e49ffdd53ed46dfbe";
    hash = "sha256-ZTN8uAfQ9RcUFCPziuRIPRdmwR0mrAHsYkkZkJT+tTk=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  buildInputs = with pkgs;
    [ glib mutter ]
    ++ pkgs.mutter.buildInputs
    ++ pkgs.mutter.propagatedBuildInputs;
}
