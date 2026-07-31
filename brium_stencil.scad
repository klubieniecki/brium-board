// =====================================================================
// Brium Board - outline stencil, ONE QUADRANT, all four corners
// ---------------------------------------------------------------------
// Stock       : 360 mm x 610 mm plywood (36 cm x 61 cm)
// Shape source: Printables "Balance Board / Stand Board and Ball"
//               sketch = 540 x 310, 110 mm end flat, R50 corners.
//               Re-solved here so the cut line touches all four edges
//               of YOUR board and stays tangent everywhere.
//
// The stencil is a rib frame sitting in the WASTE crescent between the board
// corner and the cut line. Trace the inner curved edge.
//
// Registration, two corners at a time:
//
//   Lip down  - the flanges hang 6 mm past the board edges and drop 3 mm, so
//               the template hooks the plywood corner and cannot sit anywhere
//               else. Covers corner (+,+) and, rotated 180 deg, (-,-).
//   Flipped   - the lip now faces up and cannot hook anything, so drop loose
//               pegs into the flange holes instead. Their inner tangent lies
//               exactly on the board edge line, and a through hole is
//               symmetric about the plate's mid-plane, so the registration
//               survives the flip. Covers the other two corners.
//
// One template, four corners, no mirrored second copy.
// =====================================================================

$fn = 200;

/* [Board] */
BOARD_LEN   = 610;   // long dimension of the plywood (mm)
BOARD_WID   = 360;   // short dimension of the plywood (mm)
END_FLAT    = 128;   // straight run left on each short end (mm)
CORNER_R    = 60;    // radius of the four tight corners (mm)

/* [Stencil body] */
OVERHANG    = 6;     // flange width past the board edge
FLANGE_Y0   = 60;    // end-edge flange starts here (raise for a smaller bed)
PLATE_T     = 4;     // plate thickness
LIP_T       = 3;     // how far the flange drops over the board edge (0 = flat plate)
MIRROR      = false; // true -> mirrored copy for the other two corners
PENCIL_COMP = 0;     // pencil-tip radius, e.g. 0.7 -> line lands on the true curve

/* [Lightening] */
LIGHTEN     = true;  // false -> old solid crescent
TRACE_RIB   = 9;     // width of the rib that hugs the cut line
RIB_W       = 6;     // width of the cross ribs
RIB_X       = [130, 220, 265];  // where the cross ribs sit

/* [Reversible registration] */
PEGS        = true;  // peg holes for the flipped orientation, where the lip
                     // faces up and cannot hook the board
PEG_D       = 3.3;   // peg hole dia; inner tangent sits on the board edge
PEG_X       = [80, 140, 260];  // peg holes along the long edge
PEG_Y       = [90, 150];       // peg holes along the short end edge
PEG_HEAD_D  = 8;     // peg head
PEG_HEAD_T  = 2;
PEG_STAND   = 3;     // how far the peg stands proud on the underside
PEG_FIT     = 0.15;  // shaft undersize for a press fit
PEG_NOTCH   = 10;    // width of the gap cut in the lip at each peg hole
PEG_COUNT   = 8;     // how many to lay out in PART = "pegs"

/* [Splitting for the print bed] */
SPLIT       = true;  // half-lap the quadrant into two printable pieces
SPLIT_X     = 175;   // joint position, measured from board centre
LAP_LEN     = 30;    // half-lap overlap length
LAP_TOL     = 0.2;   // fit clearance
JOINT_PAD   = 10;    // how far the solid joint patch runs past the split plane
PIN_D       = 3.2;   // vertical alignment pin (3 mm filament / M3 rod)
PIN_Y       = 178;   // where the pin goes

/* [What to render] */
// assembly | print_end | print_mid | pegs | print_all | board_preview | outline_only
PART        = "assembly";

// ---------------------------------------------------------------------
// derived geometry
// ---------------------------------------------------------------------
L  = BOARD_LEN / 2;   // 305  half length
W  = BOARD_WID / 2;   // 180  half width
A  = END_FLAT  / 2;   //  64  half of the straight end run
RC = CORNER_R;

// Long-side sweep radius, solved so that arc is tangent to the corner
// arc AND peaks exactly on the board edge at mid-length.
SWEEP_R = (pow(L - RC, 2) + pow(W - A, 2) - pow(RC, 2)) / (2 * (W - A - RC));
CY      = W - SWEEP_R;                  // sweep centre (well below the board)
CCX     = L - RC;                       // corner arc centre
CCY     = A;
THETA_T = atan2(CCY - CY, CCX);         // tangent angle, measured at the sweep centre
TX      = SWEEP_R * cos(THETA_T);
TY      = CY + SWEEP_R * sin(THETA_T);

echo(str("--- cut line ---"));
echo(str("sweep radius R  = ", SWEEP_R, " mm   centre [0, ", CY, "]"));
echo(str("corner arc      = R", RC, " centre [", CCX, ", ", CCY, "]"));
echo(str("tangent point   = [", TX, ", ", TY, "]"));
echo(str("line leaves the end edge at y = +/-", A));

STEPS = 120;

// quarter of the cut line: (L,0) -> (L,A) -> R60 arc -> sweep arc -> (0,W)
// o > 0 grows the shape outward (pencil compensation)
function quarter(o = 0) = concat(
    [[L + o, 0]],
    [ for (i = [0 : STEPS])
        let (t = THETA_T * i / STEPS)
        [CCX + (RC + o) * cos(t), CCY + (RC + o) * sin(t)] ],
    [ for (i = [1 : STEPS])
        let (t = THETA_T + (90 - THETA_T) * i / STEPS)
        [(SWEEP_R + o) * cos(t), CY + (SWEEP_R + o) * sin(t)] ]
);

function outline_pts(o = 0) =
    let (q = quarter(o), n = len(q))
    concat(
        q,
        [ for (i = [n - 2 : -1 : 1]) [-q[i][0],  q[i][1]] ],
        [ for (i = [0 : n - 1])      [-q[i][0], -q[i][1]] ],
        [ for (i = [n - 2 : -1 : 1]) [ q[i][0], -q[i][1]] ]
    );

module outline_2d(o = 0) { polygon(outline_pts(o)); }

// ---------------------------------------------------------------------
// stencil footprint
// ---------------------------------------------------------------------
PX1  = L + OVERHANG;                        // outer edge of the flanges
PY1  = W + OVERHANG;
CLX  = L + max(OVERHANG, TRACE_RIB);        // clip box: the trace rib is allowed
CLY  = W + max(OVERHANG, TRACE_RIB);        // to bulge past the flange where it must

module blank_2d()   { polygon([[0, FLANGE_Y0], [CLX, FLANGE_Y0], [CLX, CLY], [0, CLY]]); }
module onboard_2d() { polygon([[-1, -1], [L, -1], [L, W], [-1, W]]); }

// everything between the cut line and the clip box = the solid crescent
module crescent_2d() {
    difference() { blank_2d(); outline_2d(PENCIL_COMP); }
}

// --- the three things the lightened frame is made of ---------------------
// 1. a rib hugging the cut line - this is the edge you trace against
module trace_rib_2d() {
    intersection() {
        crescent_2d();
        difference() {
            offset(r = TRACE_RIB) outline_2d(PENCIL_COMP);
            outline_2d(PENCIL_COMP);
        }
    }
}
// 2. the two flange strips that hook the board edges
module flange_strips_2d() {
    intersection() {
        crescent_2d();
        union() {
            polygon([[L - 0.01, FLANGE_Y0], [PX1, FLANGE_Y0], [PX1, PY1], [L - 0.01, PY1]]);
            polygon([[0, W - 0.01], [PX1, W - 0.01], [PX1, PY1], [0, PY1]]);
        }
    }
}
// 3. cross ribs tying the two together, plus a solid patch at the joint
module cross_ribs_2d() {
    intersection() {
        crescent_2d();
        union() {
            for (x = RIB_X)
                polygon([[x - RIB_W / 2, -99], [x + RIB_W / 2, -99],
                         [x + RIB_W / 2, 999], [x - RIB_W / 2, 999]]);
            // solid patch straddling the joint: it must continue past the
            // split plane, or the cross-section steps there and the exported
            // mesh picks up T-junctions
            if (SPLIT)
                polygon([[SPLIT_X - LAP_LEN, -99], [SPLIT_X + JOINT_PAD, -99],
                         [SPLIT_X + JOINT_PAD, 999], [SPLIT_X - LAP_LEN, 999]]);
        }
    }
}

module plate_area_2d() {
    if (LIGHTEN) union() { trace_rib_2d(); flange_strips_2d(); cross_ribs_2d(); }
    else intersection() {
        crescent_2d();
        polygon([[0, FLANGE_Y0], [PX1, FLANGE_Y0], [PX1, PY1], [0, PY1]]);
    }
}

// the part hanging off the board = where the lip lives
module flange_area_2d() {
    difference() { blank_2d(); onboard_2d(); }
}

// ---------------------------------------------------------------------
// registration
// ---------------------------------------------------------------------
// REVERSIBLE mode: no moulded lip. Instead the flanges carry a row of
// through-holes whose INNER TANGENT lies exactly on the board edge line.
// Drop a peg in from whichever face is up and it sticks out 3 mm on the
// underside and butts the board edge. A through-hole is symmetric about the
// plate's mid-plane, so the part works either way up - one template, all
// four corners.
LIP = LIP_T;

module peg_holes() {
    if (PEGS) {
        for (x = PEG_X)                       // along the long edge
            translate([x, W + PEG_D / 2, -1]) cylinder(d = PEG_D, h = PLATE_T + LIP + 2);
        for (y = PEG_Y)                       // along the short end edge
            translate([L + PEG_D / 2, y, -1]) cylinder(d = PEG_D, h = PLATE_T + LIP + 2);
    }
}

module peg() {
    cylinder(d = PEG_HEAD_D, h = PEG_HEAD_T);                  // head, printed down
    cylinder(d = PEG_D - PEG_FIT, h = PEG_HEAD_T + PLATE_T + PEG_STAND);
}

// The lip is interrupted at each peg hole. Otherwise the hole would be exactly
// tangent to the lip's inner face - zero-thickness contact, and the exported
// mesh is no longer watertight. The gap also gives the peg head somewhere flat
// to sit when the template is used flipped.
module lip_area_2d() {
    difference() {
        intersection() { plate_area_2d(); flange_area_2d(); }
        if (PEGS) union() {
            for (x = PEG_X) translate([x, W + 45]) square([PEG_NOTCH, 100], center = true);
            for (y = PEG_Y) translate([L + 45, y]) square([100, PEG_NOTCH], center = true);
        }
    }
}

module stencil_solid() {
    // Printed flat. With a lip, the rail prints on top and becomes the lip
    // when you flip the part over. In REVERSIBLE mode there is no rail.
    difference() {
        union() {
            linear_extrude(PLATE_T) plate_area_2d();
            if (LIP > 0)
                translate([0, 0, PLATE_T]) linear_extrude(LIP) lip_area_2d();
        }
        peg_holes();
    }
}

// ---------------------------------------------------------------------
// half-lap joint
// ---------------------------------------------------------------------
module pin_hole() {
    translate([SPLIT_X - LAP_LEN / 2, PIN_Y, -1])
        cylinder(d = PIN_D, h = PLATE_T + LIP + 2);
}

// the volume the END piece keeps inside the lap zone (lower half)
module lap_lower(tol = 0) {
    // runs 1 mm past the split plane so the tongue overlaps the body instead
    // of butting it - a butt joint leaves coincident faces in the exported STL
    translate([SPLIT_X - LAP_LEN + tol, -50, -1])
        cube([LAP_LEN - tol + 1, 999, 1 + PLATE_T / 2 - tol]);
}

// Build the keep-volume first, then take ONE intersection with the stencil.
// Unioning two separately-intersected solids leaves coincident faces that
// show up as non-manifold edges in the exported STL.
module keep_end() {
    union() {
        translate([SPLIT_X, -50, -1]) cube([999, 999, 99]);
        lap_lower(LAP_TOL);
    }
}

module piece_end() {
    difference() {
        intersection() { stencil_solid(); keep_end(); }
        pin_hole();
    }
}

module piece_mid() {
    difference() {
        intersection() {
            stencil_solid();
            translate([SPLIT_X - 999, -50, -1]) cube([999, 999, 99]);
        }
        lap_lower(-LAP_TOL);
        pin_hole();
    }
}

module quadrant_body(part = "assembly") {
    if (!SPLIT)                   stencil_solid();
    else if (part == "print_end") piece_end();
    else if (part == "print_mid") piece_mid();
    else                        { piece_end(); piece_mid(); }
}

// mirror() rather than a negative scale, so exported STL normals stay correct
module quadrant(part = "assembly") {
    if (MIRROR) mirror([0, 1, 0]) quadrant_body(part);
    else                          quadrant_body(part);
}

// ---------------------------------------------------------------------
// output
// ---------------------------------------------------------------------
if (PART == "assembly") {
    quadrant("assembly");

} else if (PART == "print_end") {
    quadrant("print_end");

} else if (PART == "print_mid") {
    quadrant("print_mid");

} else if (PART == "print_all") {
    // laid out for a 220 x 220 bed
    translate([-(SPLIT_X - LAP_LEN), 0, 0]) quadrant("print_end");
    translate([378, 0, 0]) rotate([0, 0, 90]) quadrant("print_mid");
    if (REVERSIBLE)
        for (i = [0 : PEG_COUNT - 1])
            translate([12 + (i % 4) * 13, 6 + floor(i / 4) * 13, 0]) peg();

} else if (PART == "pegs") {
    for (i = [0 : PEG_COUNT - 1])
        translate([(i % 4) * (PEG_HEAD_D + 4), floor(i / 4) * (PEG_HEAD_D + 4), 0]) peg();

} else if (PART == "outline_only") {
    outline_2d();

} else if (PART == "board_preview") {
    color("Tan")  linear_extrude(12) square([BOARD_LEN, BOARD_WID], center = true);
    color("Sienna") translate([0, 0, 12]) linear_extrude(0.8)
        difference() { outline_2d(); offset(-1.2) outline_2d(); }
    for (sx = [1, -1], sy = [1, -1])
        color(sx * sy > 0 ? "SteelBlue" : "IndianRed")
            translate([0, 0, 12.8])
                scale([sx, sy, 1])
                    if (SPLIT) { piece_end(); piece_mid(); } else stencil_solid();
}
