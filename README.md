# ISA sound card bracket (Gravis Ultrasound PnP style)

Replacement rear slot bracket for an ISA sound card with three 3.5 mm jacks (MIC / IN / OUT) and a DA-15 game/MIDI port. Made because the original brackets rusted away.

Sheet metal, 1.0 mm. Dimensions were measured from a scan of an original bracket. I have not ordered or fitted this yet, so treat the fit as unverified.

## Files

| File | What it is |
|---|---|
| `bracket.step` | 3D model with the bend. Upload this to a sheet metal service. |
| `bracket.stl` | Same model as a mesh, for viewing or 3D printing a test fit. |
| `flat-pattern.dxf` | Flat (unfolded) cut outline, for reference. |
| `marking.dxf` | Laser marking artwork: part outline and holes (top view, folded) plus MIC / IN / OUT text, the arrow symbols, microphone and joystick icons. Text is hollow outlines with 0.2 mm lines. |
| `marking-only.dxf` | The same artwork without the part outline. |
| `bracket.scad`, `make_step.py` | Source. `make_step.py` (CadQuery) writes the STEP file. |

## Ordering (JLCCNC sheet metal)

1. Upload `bracket.step`.
2. Material: 1.0 mm cold rolled steel, or stainless 304 / aluminium 5052 if you want it rust-proof.
3. Surface treatment: laser marking, upload `marking.dxf`.

Notes:

- `marking.dxf` is AutoCAD 2000 (R2000) format. An earlier OpenSCAD-written DXF (R10 header, R14 polylines) was rejected by JLC as unreadable.
- JLC asks for laser marking text in a double-line font, 0.2 mm line width. The text in `marking.dxf` is drawn as hollow outlines with 0.2 mm lines. I have not confirmed with JLC that they accept it.
- JLC says the marking drawing should show the part after bending, with the outline and holes. `marking.dxf` is the top view of the folded part. The flange is edge-on, so its markings (none) are not shown.
- The bend uses a 0.8 mm inner radius. JLC derives the flat pattern from the STEP.
- Tab hole, jacks and DA-15 cutout were checked against a 1:1 paper print of the outline. The flange was not checked against a real bracket.
- The flange shape follows a standard ISA bracket. Check it matches your case before ordering a batch.
