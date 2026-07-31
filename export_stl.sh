#!/usr/bin/env bash
# Export every piece of the balance board stencil as a separate binary STL.
#
#   ./export_stl.sh
#
# Produces three files in ./stl/ - that is the complete print set.
# The template is reversible, so ONE copy covers all four corners.
#
# On macOS the OpenSCAD binary lives inside the .app bundle.

set -euo pipefail
cd "$(dirname "$0")"

SCAD=${SCAD:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}
[ -x "$SCAD" ] || SCAD=$(command -v openscad)

SRC=brium_stencil.scad
OUT=stl
mkdir -p "$OUT"

emit () {   # emit <outfile> <PART>
  echo "  -> $OUT/$1"
  "$SCAD" -q -o "$OUT/$1" --export-format=binstl -D "PART=\"$2\"" "$SRC"
}

echo "Exporting STLs with $SCAD"
emit brium_stencil_end.stl  print_end
emit brium_stencil_mid.stl  print_mid
emit brium_stencil_pegs.stl pegs

echo
echo "Done. Drag all three into Bambu Studio."
echo "Print flat on the bed, no supports. Pegs print head-down."
echo "One template + pegs covers all four corners: rotate 180 for the"
echo "opposite corner, flip it over and re-seat the pegs for the other two."
