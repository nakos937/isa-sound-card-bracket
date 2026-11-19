# Builds the bracket as a true B-rep (sheet metal: plate + R bend + flange) and writes STEP. Mirrors bracket.scad rev7 params.
import cadquery as cq, math
t=1.0; SH=0.55; Wd=18.55; tabw=10.2
hole_d=5.0; hole_x=109.8+SH; L=hole_x+9.66; tabx=hole_x+3.05; chl=3.6
fl_len=12.25; fl_w=18.5; js=2.0; nt_d0=4; nt_d1=9; nt_ur=2.0; nt_r=2.5; ts_u0=8; ts_u1=11; ts_d0=8; fr=0.9
xt0=6.5; xb0=4.5; ri=0.8
setb=ri+t; y0=-js+(Wd-fl_w)/2
YC=Wd/2; YH=YC-0.45; YJ=YC-0.645; jx=[16.07+SH,29.67+SH,43.27+SH]; jd=7.2
YD=YC+0.32; dx=hole_x-37.9; dwt=27.4; dwb=26.2; dh=11.05; dr=2.5; sl_h=3.1; sl_len=36.2
sh=(Wd-tabw)/2
outline=[(0,-js),(xb0,-js),(xb0+js,0),(tabx-chl,0),(tabx,sh),(L,sh),(L,Wd-sh),(tabx,Wd-sh),(tabx-chl,Wd),(xt0+js,Wd),(xt0,Wd-js),(0,Wd-js)]
# plate: x>=setb. keep outline clipped at x=setb by intersecting with a box
plate=cq.Workplane("XY").polyline(outline).close().extrude(t)
plate=plate.intersect(cq.Workplane("XY").box(300,60,10,centered=False).translate((setb,-20,-2)))
# plate holes
def cyl(x,y,d): return cq.Workplane("XY").circle(d/2).extrude(t+2).translate((x,y,-1))
cut=cyl(hole_x,YH,hole_d)
for x in jx: cut=cut.union(cyl(x,YJ,jd))
# D-cutout: hull of 4 corner circles
pts=[]
for sx in (-1,1):
    pts.append((dx+sx*(dwt/2),YD-dh/2)); pts.append((dx+sx*(dwb/2),YD+dh/2))
d=(cq.Workplane("XY").moveTo(dx-dwt/2+dr,YD-dh/2).lineTo(dx+dwt/2-dr,YD-dh/2)
   .lineTo(dx+dwb/2,YD+dh/2-dr).lineTo(dx+dwb/2-dr,YD+dh/2).lineTo(dx-dwb/2+dr,YD+dh/2)
   .lineTo(dx-dwb/2,YD+dh/2-dr).close().extrude(t+2).translate((0,0,-1)))
d=d.edges("|Z").fillet(dr*0.9)
cut=cut.union(d)
slot=cq.Workplane("XY").slot2D(sl_len,sl_h,0).extrude(t+2).translate((dx,YD,-1))
cut=cut.union(slot)
plate=plate.cut(cut)
# bend: quarter ring, axis along Y at x=setb, z=-ri ; goes from plate underside tangent down to flange
bend=(cq.Workplane("XZ").moveTo(setb,t).lineTo(setb,0)   # placeholder profile replaced below
      )
ring=(cq.Workplane("XZ").center(setb,-ri).circle(ri+t).circle(ri).extrude(-fl_w).translate((0,y0,0)))
# keep only the quadrant x<=setb, z>=-ri
keep=cq.Workplane("XY").box(setb,fl_w,ri+t,centered=False).translate((0,y0,-ri))
bend=ring.intersect(keep)
# flange: vertical plate x in [0,t], from z=-ri downward length (fl_len - setb)
fl_flat=fl_len-setb
# flange in (y,z): box, then 3MF side notch + top slot
flange=cq.Workplane("XY").box(t,fl_w,fl_flat,centered=False).translate((0,y0,-ri-fl_flat))
zfree=-ri-fl_flat; zd=lambda d: t-d      # d = distance from mould line (plate top) ; z = t-d
def bx(u0,u1,d0,d1): return cq.Workplane("XY").box(t+2,u1-u0,d1-d0,centered=False).translate((-1,y0+u0,zd(d1)))
cutf=bx(-1,nt_ur,nt_d0,nt_d1).union(cq.Workplane("YZ").circle(nt_r).extrude(t+2).translate((-1,y0+nt_ur,zd((nt_d0+nt_d1)/2))))
cutf=cutf.union(bx(ts_u0,ts_u1,ts_d0,fl_len+1))
flange=flange.cut(cutf)
flange=flange.edges(cq.selectors.BoxSelector((-1,y0-1,zfree-0.1),(t+1,y0+0.1,zfree+0.1))).fillet(fr) if False else flange
body=plate.union(bend).union(flange)
cq.exporters.export(body,"bracket.step")
bb=body.val().BoundingBox()
print("solid valid:",body.val().isValid(),"volume %.1f mm3"%body.val().Volume())
print("bbox X %.2f..%.2f Y %.2f..%.2f Z %.2f..%.2f"%(bb.xmin,bb.xmax,bb.ymin,bb.ymax,bb.zmin,bb.zmax))
