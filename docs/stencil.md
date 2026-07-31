# Brium Board — stencil design notes

> Build guide and materials list: [../README.md](../README.md)

A parametric OpenSCAD stencil for laying out the rounded cut line of a balance
board on **360 × 610 mm** plywood (36 × 61 cm), derived from the Printables
["Balance Board Stand Board and Ball"](https://www.printables.com/model/1341613-balance-board-stand-board-and-ball)
sketch.

One printed quadrant marks all four corners.

---

## The geometry

The reference sketch is a 540 × 310 outline built from four elements per side:

| Element | Reference (540 × 310) | Yours (610 × 360) |
| --- | --- | --- |
| Overall length | 540 mm | **610 mm** (full stock) |
| Overall width | 310 mm | **360 mm** (full stock) |
| Straight flat on each short end | 110 mm | **128 mm** |
| Corner radius | R50 | **R60** |
| Long-side sweep radius | R559 (solved) | **R623.94 (solved)** |
| Sweep centre, below the long centreline | 404 mm | **443.94 mm** |
| Arcs meet tangent at | (271.1, 118.0) equivalent | **(271.1, 118.0)** |

The sweep radius is not a free choice. It is solved so the long arc is
simultaneously **tangent to the corner arc** and **peaks exactly on the board
edge at mid-length**:

```
R = ( (L - rc)² + (W - a)² - rc² ) / ( 2 · (W - a - rc) )

L  = 305  half length          a  = 64  half the end flat
W  = 180  half width           rc =  60  corner radius
```

That single formula is what keeps the whole outline smooth — no visible kink
where the corner meets the long sweep. Change `END_FLAT` or `CORNER_R` in the
.scad and the sweep re-solves itself.

Origin is the centre of the board. The cut line leaves the short end edge at
**y = ±64 mm** and touches the long edge at **x = 0**.

---

## How the stencil works

The printed part is the *waste crescent* between the board corner and the cut
line — the material you will be cutting away.

Trace along the inner curved edge.

### Registration — and why one template does all four corners

The outline is symmetric about both centrelines, so the *shape* at every corner
is the same. But a quadrant is not mirror-symmetric: two corners want it
left-handed, two want it right-handed. A flat part handles that — you flip it
over. The only thing that can break the flip is a feature living on one face,
which is exactly what a moulded lip is. So the template carries both:

| Corner | Orientation | Registration |
| --- | --- | --- |
| top-right | lip down | flanges hook the plywood corner |
| bottom-left | lip down, rotated 180° | same |
| top-left | flipped (lip up) | drop pegs into the flange holes |
| bottom-right | flipped, rotated 180° | same |

**Lip down** — the flanges hang 6 mm past the board edges and drop 3 mm. Seat
it on the corner and it hooks both edges; it can't sit anywhere else. No
measuring, no squaring up.

**Flipped** — the lip now faces up and hooks nothing, so the pegs take over.
Their holes are positioned so the **inner tangent of the peg lies exactly on
the board edge line**. A through-hole is symmetric about the plate's
mid-plane, so this survives the flip. Five holes: three along the long edge
(x = 80, 140, 260) and two along the short end (y = 90, 150). Three would
locate it; five means you can skip one if a clamp is in the way.

The lip is interrupted by a 10 mm gap at each peg hole — partly so the hole
isn't tangent to the lip's inner face (that made the export non-manifold),
partly to give the peg head somewhere flat to sit.

### Filament

A rib frame, not a solid plate: a 9 mm rib hugging the cut line, a 6 mm flange
strip along each board edge, three cross ribs, and a solid patch at the joint.
Everything else is open.

| | Solid, lipped, 15 mm flange | Lean rib frame |
| --- | --- | --- |
| Corner piece | 74.3 cm³ | **20.7 cm³** |
| Mid piece | 25.7 cm³ | **11.9 cm³** |
| 8 pegs | — | **1.2 cm³** |
| Copies needed for 4 corners | 2 (one mirrored) | **1** |
| **Total** | **200 cm³** | **33.8 cm³** (−83%) |

Ribs only pay where the frame is actually open. Below about x = 105 the trace
rib and the flange merge into one bar, so ribs there were doing nothing — the
count went 5 → 3 for that reason, not to shave grams.

Levers if you want less still: `TRACE_RIB` 9 → 8 (−1.5 cm³, but the pencil
edge gets narrow), `PLATE_T` 4 → 3.5 (the half-lap tongue is already only
1.8 mm — I would not). `LIGHTEN = false` goes back to the solid crescent.

### Printing

The quadrant is 319 × 129 mm, so it is half-lapped into two pieces that pin
together with a 3 mm rod (or a stub of filament) through the joint.

| Piece | Size | Notes |
| --- | --- | --- |
| `print_end` | 169 × 129 × 7 mm | the corner half, does the R60 and most of the sweep |
| `print_mid` | 175 × 34 × 7 mm | the thin half that reaches the board's mid-length |
| `pegs` | 8 buttons, 44 × 20 | registration pegs, print a couple spare |

Print **flat on the bed, no supports** — the plate goes down first and the lip
rail prints on top of it, so nothing overhangs. Flip each piece over to use it.
Pegs print head-down. Everything fits a 180 mm bed.

Do not export `PART = "assembly"` — that is the two pieces mated, 319 mm long.

#### Exporting the STLs

`./export_stl.sh` writes the whole print set to `stl/` as binary STLs:

| File | What it is |
| --- | --- |
| `brium_stencil_end.stl` | the corner half of the template |
| `brium_stencil_mid.stl` | the half that reaches the board's mid-length |
| `brium_stencil_pegs.stl` | 8 registration pegs |

Three prints, all four corners. All watertight, single-body, correct winding —
Bambu Studio imports them without a repair prompt. Or by hand: set `PART` to
`print_end` / `print_mid` / `pegs`, F6, then File → Export → Export as STL.

For a 180 mm bed, raise `FLANGE_Y0` (currently 30) to about 60, or move
`SPLIT_X` down to ~155.

Render targets (`PART = ...`):

| Value | Shows |
| --- | --- |
| `assembly` | both pieces joined — the full quadrant |
| `print_end` / `print_mid` | one piece, ready to export as STL |
| `print_all` | both laid out for a 220 × 220 bed |
| `board_preview` | the stock, the cut line, and all four stencils in place |
| `outline_only` | the raw 2D cut line (export as DXF/SVG for a 1:1 paper template) |

### Using it

1. Mark the two centrelines on the plywood (mid-length and mid-width).
2. Lip down, hook the template over a corner — both flanges hard against the
   board edges. The straight edge at the mid-length end should land on your
   centreline; that is your check that the geometry is right.
3. Trace the inner curve. Set `PENCIL_COMP` to your pencil-tip radius
   (≈ 0.7 mm) if you want the drawn line to land dead on the true curve.
4. Rotate 180° for the opposite corner. For the remaining two, flip the
   template over, press the pegs in, and seat them against the board edges.
5. The short ends are already straight — the cut line runs along the existing
   edge for 128 mm before it curves away.

---

## Parameters worth touching

| Parameter | Default | Effect |
| --- | --- | --- |
| `END_FLAT` | 128 | longer flat = squarer ends, flatter sweep |
| `CORNER_R` | 60 | tighter corners = more aggressive nose |
| `OVERHANG` / `LIP_T` | 6 / 3 | flange width past the edge, and lip depth |
| `PEGS` | true | peg holes for the flipped orientation |
| `TRACE_RIB` / `RIB_W` / `RIB_X` | 9 / 6 / 3 ribs | frame proportions |
| `PEG_X` / `PEG_Y` | lists | where the registration pegs sit |
| `LIGHTEN` | true | rib frame instead of a solid crescent |
| `PLATE_T` | 4 | plate thickness |
| `SPLIT_X` | 175 | where the two pieces meet |
| `PENCIL_COMP` | 0 | grows the curve by the pencil-tip radius |
| `MIRROR` | false | mirrored copy for the other two corners |
