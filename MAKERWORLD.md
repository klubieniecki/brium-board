# MakerWorld listing — copy/paste

Everything below is ready to paste. Drop in your photos where noted.

---

## Title

```
Brium Board — balance board layout stencil for one 2×2 plywood sheet
```

## Summary / tagline

```
Brium (from aequilibrium). A 3D-printed jig that draws dtxtr's balance board profile onto a 610 × 610 mm plywood sheet. One template, all four corners, symmetric by construction.
```

## Tags

```
brium, balance board, wobble board, stencil, template, jig, woodworking, plywood, openscad, parametric, lacrosse ball, balance trainer, layout tool
```

## Category

Tools & Gadgets → Woodworking / Jigs

---

## Description

**Brium** — the tail end of *aequilibrium*. Latin for balance, minus the run-up.

**This is a layout jig, not the board itself.**

I wanted to build [dtxtr's balance board and
stand](https://www.printables.com/model/1341613-balance-board-stand-board-and-ball)
but I had a 2 ft × 2 ft plywood sheet — 610 × 610 mm — and his profile is drawn
for 540 × 310. Scaling a curve like that by eye doesn't work, and freehanding a
600 mm sweep arc symmetrically across four corners *really* doesn't work.

So I re-derived the profile for the larger sheet and made a stencil to draw it.

### What it does

Rip your 2×2 sheet down to **360 × 610 mm** and the stencil lays the full
rounded outline onto it. The profile touches all four edges of the blank, so you
use every millimetre of the sheet, and the 250 mm offcut is exactly enough for
the ball guard.

The printed part is the **waste crescent** between the board corner and the cut
line — the bit you're about to saw off. You trace along its inner edge.

### One template covers all four corners

The outline is symmetric about both centrelines, so the shape at every corner is
identical. The catch is handedness: two corners want it left-handed, two want it
right-handed. A flat part solves that by flipping over — the trick was making it
register **both ways up**.

- **Lip down** — the flanges hang 6 mm past the board edges and drop 3 mm. Seat
  it on a corner and it hooks both edges. It physically cannot sit anywhere
  else. That's two corners (rotate 180° for the second).
- **Flipped** — the lip now faces up and hooks nothing, so five loose pegs take
  over. Their holes are placed so the *inner tangent of the peg* sits exactly on
  the board edge line, and a through-hole is symmetric about the plate's
  mid-plane, so the registration survives the flip. That's the other two.

No mirrored second copy. No measuring. No squaring anything up.

### The geometry

The long sweep radius isn't a number I picked — it's solved so the arc is
tangent to the corner arc *and* peaks exactly on the board edge at mid-length:

```
R = ( (L − rc)² + (W − a)² − rc² ) / ( 2 · (W − a − rc) )
```

For a 610 × 360 board with a 128 mm end flat and R60 corners, that gives
**R = 623.94 mm**, centred 443.94 mm below the long centreline. That's what
keeps the outline fair — no kink where the corner meets the sweep.

The source is parametric OpenSCAD. Different sheet? Change two numbers and the
whole profile re-solves.

### What you print

| File | Size |
| --- | --- |
| `brium_stencil_end.stl` | 169 × 129 × 7 mm |
| `brium_stencil_mid.stl` | 175 × 34 × 7 mm |
| `brium_stencil_pegs.stl` | 8 pegs |

The two halves join with a half-lap and a 3 mm pin (a brad nail or a doubled
stub of filament works). About **34 cm³** of plastic for the whole set — roughly
40 g.

### Print settings

- **Flat on the bed, no supports.** The plate prints first and the lip rail on
  top of it, so nothing overhangs. Flip each piece over to use it.
- Pegs print head-down.
- 3 walls, 15 % infill, 0.2 mm layers. It's a jig — it wants stiffness, not
  strength.
- Fits a 180 mm bed.

A ready-to-slice `.3mf` is included with the plates already arranged.

### You'll also need

- The stand and ball guard from **[dtxtr's original
  model](https://www.printables.com/model/1341613-balance-board-stand-board-and-ball)** — not
  included here, go download them from him
- 610 × 610 × 12 mm plywood (his stand is sized for 12 mm stock)
- A lacrosse ball
- A jigsaw or bandsaw, and something to sand the curve back to the line

---

## Credits

**The board profile, the stand and the ball guard are all
[dtxtr's](https://www.printables.com/@dtxtr_339032) work** —
["Balance Board Stand (board and ball)"](https://www.printables.com/model/1341613-balance-board-stand-board-and-ball).
All I did was re-derive his outline for a bigger sheet and build a jig to draw
it. If you make this, go like and follow his model first.

Full build guide, the parametric OpenSCAD source, and the maths behind the
sweep radius:
**https://github.com/klubieniecki/brium-board**

Remixes welcome — the source is CC BY-SA 4.0. If you adapt it for a different
sheet size, post a make and tell me the numbers you used.

---

## Photos to upload (in this order)

1. Finished Brium board on the stand — the money shot, this becomes the thumbnail
2. Stencil hooked on a plywood corner, pencil mid-trace
3. The full outline traced, before cutting
4. Both halves pinned together, on the board
5. Render of all four corners covered (`docs/images/board_preview.png`)
6. The cut-line dimension diagram (`docs/images/cutline_diagram.png`)
7. Print layout render (`docs/images/print_layout.png`)

<!-- MakerWorld weights the first image heavily in the feed. A real photo of a
     finished wooden board will out-perform a render every time — lead with it,
     and keep the renders for slots 5-7. -->

---

## Before you publish

- MakerWorld's licence selector: pick **CC BY-SA** to match the repo.
- Upload **only your own stencil files.** Don't re-host dtxtr's stand — link to
  it. Re-uploading someone else's model is the fastest way to get a listing
  pulled, and the link sends him the traffic anyway.
- If you enter it in a MakerWorld contest, check the rules on derivative
  works — a jig for someone else's model is usually fine, but the entry terms
  are worth a read.
