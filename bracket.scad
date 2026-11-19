// ISA bracket rev7, mm. Cut geometry from pen-trace scan (1200 dpi, pen offset 0.65 mm removed).
// MODE: "cut" flat cut pattern, "mark" engraving only, "3d" folded preview.
MODE="3d";
t=1.0;                 // cold rolled steel 1.0 mm (JLC)
SH=0.55;                 // plate extends this much further on flange side than rev5 (trace fit)
Wd=18.55;
tabw=10.2;
hole_d=5.0; hole_x=109.8+SH;      // anchor: tab hole centre (scan)
L=hole_x+9.66; tabx=hole_x+3.05; chl=3.6;   // tab end, chamfer end, chamfer length (rel. hole, scan)
// flange: hooked ISA flange from user 3MF (ISA_USB): 18.5 wide, 12.25 tall (from mould line), side notch + top slot
fl_len=12.25; fl_w=18.5; js=2.0;   // joggle 2.0 from 3MF
nt_d0=4; nt_d1=9; nt_ur=2.0; nt_r=2.5;     // side notch: d 4..9 from mould line, round end centre 2.0 in from side edge
ts_u0=8; ts_u1=11; ts_d0=8;                // top slot: u 8..11 across, from d 8 to free end
fr=0.9;                                    // free-end corner radius
xt0=6.5; xb0=4.5;                  // joggle chamfer starts (top edge / bottom edge), 45 deg, from trace
ri=0.8; K=0.4;                     // JLC 1.0 mm cold rolled: outer R 1.8 -> inner 0.8; K 0.4 is a starting value (JLC gives none)
setb=ri+t;                         // setback: mould line to bend tangent
BA=PI/2*(ri+K*t);                  // bend allowance 90 deg
fl_flat=fl_len-setb;               // flat flange length beyond the bend
y0=-js+(Wd-fl_w)/2;                // flange lower edge
YC=Wd/2;
YH=YC-0.45;  // NOTE Y values below were measured from the plate centre line; plate is 18.7 wide now
YJ=YC-0.645;  jx=[16.07+SH,29.67+SH,43.27+SH];   // jacks MIC, IN, OUT (scan, anchored on tab hole)
jd=7.2;
YD=YC+0.32;  dx=hole_x-37.9;            // DA-15 centre (scan, rel. tab hole)
dwt=27.4; dwb=26.2; dh=11.05; dr=2.5;  // D-cutout (scan): wide side toward -Y
sl_h=3.1; sl_len=36.2;                 // standoff slot, tip to tip (scan)
$fn=48;

module outline() {
  sh=(Wd-tabw)/2;
  polygon([[0,-js],[xb0,-js],[xb0+js,0],[tabx-chl,0],[tabx,sh],[L,sh],[L,Wd-sh],[tabx,Wd-sh],[tabx-chl,Wd],[xt0+js,Wd],[xt0,Wd-js],[0,Wd-js]]);
}
module slot2d(x0,x1,y,h) { hull(){ translate([x0+h/2,y]) circle(d=h); translate([x1-h/2,y]) circle(d=h); } }
module cutouts() {
  translate([hole_x,YH]) circle(d=hole_d);
  for (x=jx) translate([x,YJ]) circle(d=jd);
  translate([dx,YD]) hull(){
    for (sx=[-1,1]) { translate([sx*(dwt/2-dr),-dh/2+dr]) circle(r=dr); translate([sx*(dwb/2-dr), dh/2-dr]) circle(r=dr); }
  }
  slot2d(dx-sl_len/2,dx+sl_len/2,YD,sl_h);
}
module flange_ud() {                 // flange in (u across, d from mould line), free end at d=fl_len
  difference(){
    union(){
      difference(){ square([fl_w,fl_len]);
        for (c=[[0,fl_len],[fl_w,fl_len]]) translate([c[0]==0?-0.01:fl_w-fr,fl_len-fr]) difference(){ square([fr+0.01,fr+0.01]); translate([c[0]==0?fr:0,0]) circle(r=fr,$fn=32); } }
    }
    translate([0,nt_d0]) square([nt_ur,nt_d1-nt_d0]);
    translate([nt_ur,(nt_d0+nt_d1)/2]) circle(r=nt_r,$fn=48);
    translate([ts_u0,ts_d0]) square([ts_u1-ts_u0,fl_len]);
  }
}
module flange2d() {           // unrolled: plate tangent at x=setb, bend zone left of it, flange beyond
  translate([setb-BA,y0]) square([BA+0.01,fl_w]);
  multmatrix([[0,-1,0,2*setb-BA],[1,0,0,y0],[0,0,1,0],[0,0,0,1]])
    intersection(){ flange_ud(); translate([-1,setb]) square([fl_w+2,fl_len]); }
}
module bend_line() { translate([setb-BA/2,y0]) square([0.05,fl_w]); }   // reference only
// ---- engraving (outside face; flange-left view as in scan; text rotated 180 as on original) ----
lw=0.2; ty=Wd-3.0; th=2.4;
module ring(r,a0,a1) { intersection(){ difference(){circle(r=r+lw/2);circle(r=r-lw/2);} polygon(concat([[0,0]],[for(a=[a0:6:a1])[6*cos(a),6*sin(a)]])); } }
module bar(x0,y0,x1,y1) { hull(){ translate([x0,y0]) circle(d=lw); translate([x1,y1]) circle(d=lw);} }
module sig(dir) { // photo 9/10: 3 concentric rings split into dome+bowl with side gaps, arrow shaft through centre; dir=+1 head up
  mirror([0,dir<0?1:0]) {
    for (r=[0.8,1.3,1.8]) { ring(r,12,168); ring(r,192,348); }
    bar(0,-0.2,0,2.9);                       // shaft
    bar(0,2.9,-0.55,2.3); bar(0,2.9,0.55,2.3);   // outer head
    bar(0,0.3,-0.45,-0.25); bar(0,0.3,0.45,-0.25); // inner chevron
  }
}
module cap(l,w) { hull(){ translate([0,0]) circle(d=w); translate([l,0]) circle(d=w);} }
module outl(w=lw) { difference(){ offset(delta=w/2) children(); offset(delta=-w/2) children(); } }
module mic() { rotate(-30) {
  translate([0,1.5]) outl() circle(r=0.95);
  translate([0,1.5]) for(a=[-0.4,0.4]) bar(a,-0.5,a,0.5);
  rotate(90) translate([-0.55,0]) outl() cap(2.6,0.9);
  for (r=[1.5,2.0]) translate([0,1.5]) ring(r,105,165);
} }
module joy() { // scan: lever capsule runs into a diamond pointing toward the tab. Origin = diamond centre.
  difference(){ outl() polygon([[-1.3,0],[0,1.95],[1.3,0],[0,-1.95]]);
                translate([-3.15,0.15]) offset(delta=lw) cap(1.8,1.5); }
  translate([-3.15,0.15]) outl() cap(1.8,1.5);
}
module marks() {
  for (i=[0:2]) translate([jx[i],ty]) rotate(180) outl(0.2) text(["MIC","IN","OUT"][i],size=th,halign="center",valign="center",font="Liberation Sans:style=Bold");
  translate([(jx[0]+jx[1])/2,YJ+0.2]) rotate(180) sig(1);
  translate([(jx[1]+jx[2])/2,YJ+0.2]) rotate(180) sig(-1);
  translate([jx[0]-5.5,YJ]) rotate(180) mic();
  translate([hole_x-15.2,YH+0.1]) joy();   // scan: diamond centre 15.2 left of tab hole
}
module cutflat() { difference(){ union(){ intersection(){ outline(); translate([setb,-20]) square([200,60]); } flange2d(); } cutouts(); } }
module bend3d() translate([setb,y0+fl_w,-ri]) rotate([90,0,0]) rotate([0,0,90]) rotate_extrude(angle=90,$fn=64) translate([ri,0]) square([t,fl_w]);
module part3d() {
  linear_extrude(t) difference(){ intersection(){ outline(); translate([setb,-20]) square([200,60]); } cutouts(); }
  bend3d();
  translate([0,y0,t]) multmatrix([[0,0,1,0],[1,0,0,0],[0,-1,0,0],[0,0,0,1]]) linear_extrude(t) intersection(){ flange_ud(); translate([-1,setb]) square([fl_w+2,fl_len]); }
}
module part_plate_only() { linear_extrude(t) difference(){ intersection(){ outline(); translate([setb,-20]) square([200,60]); } cutouts(); } bend3d(); }
if (MODE=="outline") projection(cut=false) part_plate_only();
else if (MODE=="markout") { outl(0.2) projection(cut=false) part_plate_only(); marks(); }   // outline drawn as 0.2 mm line so the marks stay separate
else if (MODE=="cut") cutflat();
else if (MODE=="mark") marks();
else { part3d(); color("red") translate([0,0,t]) linear_extrude(0.05) marks(); }
