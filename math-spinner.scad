/* Electronic Math Spinner */

/* [Global] */

// Which part.
part = "all"; // [ring1a, ring1b, ring1c, ring2, ring3, insert, lid1, lid2]

/* [Hidden] */
function inch() = 25.4;

function ring_outer_diam() = 80;
function neopixel_led_height() = 8.7 - 1.0/*shoulder*/;
function pcb_size() = [40,48];
function lid1_thick() = 1.5;
function lid2_thick() = 1.5;
function lid2_wall_thick() = neopixel_led_height() - 1; // let 1mm protrude
function lid2_screw_foot() = 9;
function screw_4_40_tap() = 0.0860*inch(); // tap drill for 4-40 screw
function screw_4_40_clearance() = .1285 * inch(); // clearance drill for 4-40
function clearance() = 0.25;
$fn=50;

rotate([0,-90,0])
spinner_part(which=part);

module spinner_part(which="all") {
  slip_ring_height=17.3; // default slip ring height
  if (which=="all") {
    spacing=slip_ring_height + 3.5;
    translate([0,0,0*spacing - 10]) {
      color("purple") spinner_part("ring1c");
      spinner_electronics(pretty=true);
      color("grey") translate([0,0,-.5])
        spinner_part("lid2");
    }
    translate([0,0,1*spacing - 5]) {
      color("blue") spinner_part("ring1b");
    }
    translate([0,0,2*spacing - 5]) {
      color("green") spinner_part("ring3");
    }
    translate([0,0,3*spacing]) {
      color("yellow") spinner_part("ring1b");
    }
    translate([0,0,4*spacing]) {
      color("orange") spinner_part("ring2");
    }
    translate([0,0,5*spacing]) {
      color("red") spinner_part("ring1a");
      translate([0,0,0.5])
      color("grey") spinner_part("lid1");
    }
  }
  if (which=="insert") {
    spinner_insert();
  }
  if (which=="ring") {
    spinner_ring(slip_ring_height=slip_ring_height);
  }
  if (which=="ring1a") {
    // two variants: one with no_led = true, and one with
    // no_switch=true (which would hollow out a space for electronics)
    spinner_ring(label="0123456789", slip_ring_height=slip_ring_height);
  }
  if (which=="ring1b") {
    // internal ring.
    spinner_ring(label="0123456789", no_led=true, slip_ring_height=slip_ring_height);
  }
  if (which=="ring1c") {
    spinner_ring(label="0123456789", no_led=true, no_switch=true, extra_height=5, slip_ring_height=slip_ring_height);
  }
  if (which=="ring2") {
    spinner_ring(label="0+−×÷+−×÷+−", no_led=true, slip_ring_height=slip_ring_height);
  }
  if (which=="ring3") { // extra long (12-wire slip ring)
    spinner_ring(label="0=>=<=>=<=>=<=", no_led=true, slip_ring_height=slip_ring_height + 5);
  }
  if (which=="lid1") {
    spinner_lid1(); // lid for ring1a
  }
  if (which=="lid2") {
    spinner_lid2(); // lid for ring1c
  }
  if (which=="lid2a" || which=="lid2b") {
    // split lid2 in half so we can get highest quality print on text side
    split_plane = 0.6;
    intersection() {
      spinner_lid2();
      translate([0,0,-lid2_thick()+split_plane]) scale([1,1,which=="lid2a"?1:-1])
        translate([0,0,50]) cube([100,100,100], center=true);
    }
  }
  if (which=="shim") {
    cube([12,12,0.4]);
  }
  if (which=="ring-test") {
    intersection() {
      spinner_ring(no_feet=true, slip_ring_height=slip_ring_height);
      cylinder(d=32, h=100, $fn=10);
    }
  }
  if (which=="lid-test") {
    spinner_part("ring1c");
    spinner_electronics(pretty=true);
    spinner_part("lid2");
  }
}

module spinner_insert(slip_ring_diam=12.5, clearance=clearance()) {
  height = 14.5;
  switch_outer_diam = 18.5;
  switch_inner_diam = 17.5;
  flange1_width = 2.7;
  flange2_width = 6.9;
  flange3_width = 1.4;
  epsilon = 0.1;
  cl = clearance;

  difference() {
    union() {
      cylinder(d=switch_inner_diam - 2*cl, h=height);
      intersection() {
        cylinder(d=switch_outer_diam - 2*cl, h=height);
        union() {
          cube([3*switch_outer_diam, flange1_width - 2*cl, 3*height],
               center=true);
          cube([flange2_width - 2*cl, 3*switch_outer_diam, 3*height],
               center=true);
        }
      }
    }
    translate([0,0,-epsilon])
     cylinder(d=slip_ring_diam + 2*cl, h=height+2*epsilon);
    for (i=[1,-1]) scale([1,i,1])
     translate([-flange3_width/2 - cl,
                switch_inner_diam/2 - 0.5 - cl,
                -epsilon])
       cube([flange3_width + 2*cl, switch_inner_diam, height+2*epsilon]);
  }
}

module spinner_ring_tab(extra=0, extra_deep=0, clearance=clearance()) {
  cheat = 0.25; // increase this to make the tabs snap into place more
  tab_offset = 8.25;
  tab_height = 11.85 - tab_offset;
  tab_width = 3.8;
  tab_inner_diam = 21.5 - 2*.75;
  tab_thick = 2 + cheat;
  tab_stem_thick = 2;
  tab_stem_height = 4;
  epsilon = .1;
  cl = clearance;

  translate([0, tab_inner_diam/2 + cl - cheat, tab_offset + cl]) {
    // the angled cube which goes into the slot
    difference() {
      translate([-tab_width/2 + cl - extra, -extra, -extra - extra_deep])
        cube([tab_width - 2*cl + 2*extra, tab_thick + epsilon + 2*extra, tab_height - 2*cl + 2*extra + extra_deep]);
      if (extra==0) translate([-tab_width/2 - epsilon, .75, 0])
        scale([1,-1,1]) rotate([-25,0,0])
        cube([tab_width + 2*epsilon, 2, tab_height]);
    }
    // the stem which makes this flexible
    translate([-tab_width/2 + cl - extra, tab_thick - extra, -extra - extra_deep])
      cube([tab_width - 2*cl + 2*extra, tab_stem_thick + 3*extra, tab_height + tab_stem_height + extra + extra_deep + (extra>0 ? -epsilon : 0)]);
  }
}

module spinner_ring(ring_outer_diam=ring_outer_diam(), slip_ring_height=17.3, label="", no_feet=false, no_led=false, no_switch=false, extra_height=0, clearance=clearance()) {
  slip_ring_clearance = 3 + extra_height; // for routing wires
  pcb_clearance = 4; // length of switch pins
  pcb_thick = 1.7;
  pcb_size = pcb_size();
  standoff_offset = 4;
  standoff_screw_diam = screw_4_40_tap();
  standoff_screw_depth = 100; // easier to tap if holes go all the way through
  standoff_foot_diam = 7;
  alignment_hole_diam = 4;
  alignment_hole_head_diam = 5;
  alignment_hole_foot_diam = 6; /* >3.4 */;
  alignment_hole_offset = 6;
  letter_deep = 1;

  switch_clearance_diam = 32;
  switch_clearance_height = 6.8;
  switch_locator_height = 9;
  cl = clearance;
  $fn = 50;

  epsilon = .1;

  if (!no_switch)
    for(i=[-1,1]) scale([1,i,1])
      spinner_ring_tab(clearance=clearance);
  difference() {
    // outer decagon
    cylinder(d=ring_outer_diam, h=slip_ring_height+slip_ring_clearance, $fn=10);
    union() {
      // pcb top clearance
      if (!no_switch) translate([0,0,-epsilon])
        cylinder(d=sqrt(pcb_size.x*pcb_size.x + pcb_size.y*pcb_size.y)+2*cl,
                 h=2.5+epsilon);
      // alignment hole
      rotate([0,0,18])
      translate([0,ring_outer_diam/2 - alignment_hole_offset,-epsilon]) {
        cylinder(d=alignment_hole_diam + 2*cl, h=100);
        if (!no_led)
        translate([0, 0,
                   slip_ring_height+slip_ring_clearance-pcb_clearance+epsilon]){
          cylinder(d=alignment_hole_foot_diam + 2*cl, h=pcb_clearance+epsilon);
          translate([0,0,-9])
            cylinder(d=alignment_hole_head_diam + 2*cl, h=10);
          for (i=[0,-18]) rotate([0,0,i])
          translate([-alignment_hole_diam/2 - cl, 0, 0]) scale([1,-1,1])
            cube([alignment_hole_diam + 2*cl,
                ring_outer_diam/2 - alignment_hole_offset,
                pcb_clearance + epsilon]);
        }
      }
      // clearance for outside of switch
      if (!no_switch)
        translate([0,0,-epsilon])
        cylinder(d=switch_clearance_diam + 2*cl, h=switch_clearance_height+epsilon);
      // slip ring clearance
      translate([0,0,-epsilon])
        cylinder(d=18 + 2*cl, h=slip_ring_height+slip_ring_clearance+2*epsilon);
      // engagement w/ switch
      if (!no_switch) {
        for(i=[-1,1]) scale([1,i,1])
          spinner_ring_tab(extra=0.75, extra_deep=2, clearance=0);
        difference() {
          cylinder(d=21.5 + 2*cl, h=15);
          difference() {
            translate([0,0,50 + switch_locator_height])
              cube([100, 2.25 - 2*cl, 100], center=true);
            cylinder(d=20.5 + 2*cl, h=101, center=true);
          }
        }
      }
      // pcb cutout
      translate([0, 0, slip_ring_height + slip_ring_clearance - pcb_clearance]){
        difference() {
          translate([-pcb_size.x/2 - cl, -pcb_size.y/2 - cl, 0])
            cube([pcb_size.x + 2*cl, pcb_size.y + 2*cl, pcb_clearance + epsilon]);
          if (!no_feet) for (i=[1,-1]) for (j=[-1,1]) scale([i,j,1])
            translate([-pcb_size.x/2 + standoff_offset,
                       -pcb_size.y/2 + standoff_offset,
                       -epsilon]) {
              cylinder(d=standoff_foot_diam, h=pcb_clearance-pcb_thick+epsilon);
            }
        }
      }
      // screw holes for pcb feet
      for (i=[1,-1]) for (j=[-1,1]) scale([i,j,1])
        translate([-pcb_size.x/2 + standoff_offset,
                   -pcb_size.y/2 + standoff_offset,
                   slip_ring_height + slip_ring_clearance - pcb_clearance
                    - standoff_screw_depth])
          cylinder(d=standoff_screw_diam + 2*cl,
                   h=standoff_screw_depth + pcb_clearance);
      // lettering on outside
      if (label != "") {
        for (i=[0:9]) rotate([0,0,i*36]) {
          letter = label[i];
          apothem = (ring_outer_diam/2)*cos(180/10/*sides*/);
          translate([0,apothem-letter_deep,(slip_ring_height+slip_ring_clearance-extra_height)/2 + extra_height]) {
            if (no_switch) {
              translate([0,0,-10]) rotate([-90,0,0])
                translate([0,0,letter_deep - ring_outer_diam/2])
                cylinder(d=5,h=ring_outer_diam);
            }
            rotate([-90,0,0]) rotate([0,0,90]) linear_extrude(height=2*letter_deep)
              text(text=letter,
                   size=ring_outer_diam/6,
                   halign="center", valign="center",
                   font="Lato:style=Bold");
          }
        }
      }
      if (no_switch) { // hollow out ring for electronics
        bottom_wall_thick = 2;
        outer_wall_thick = lid2_wall_thick();
        alignment_depth = 20;
        spinner_lid2_screws(ring_outer_diam=ring_outer_diam,
                            d=screw_4_40_tap());
        spinner_electronics(extra=clearance, pretty=false);
        difference() {
          union() {
            translate([0,0,-epsilon])
              cylinder(d=ring_outer_diam - 2*outer_wall_thick,
                       h=slip_ring_height+slip_ring_clearance+epsilon
                       - pcb_clearance - bottom_wall_thick,
                       $fn=10);
          }
          // lid feet
          spinner_lid2_screws(ring_outer_diam=ring_outer_diam,
                              d=lid2_screw_foot());
          // pcb feet (extended)
          for (i=[1,-1]) for (j=[-1,1]) scale([i,j,1])
            translate([-pcb_size.x/2 + standoff_offset,
                       -pcb_size.y/2 + standoff_offset,
                       slip_ring_height + slip_ring_clearance
                       - 13 /* 1/2in long screws */])
              cylinder(d=standoff_foot_diam + 2*cl, h = 13 + epsilon);
          // led alignment hole, extended
          rotate([0,0,18])
          translate([0,ring_outer_diam/2 - alignment_hole_offset,
                     epsilon + (slip_ring_height + slip_ring_clearance)
                     -alignment_depth])
            cylinder(d=10, h=100);
          // power switch support
          rotate([0,0,-1.5*36]) translate([0,-30.5,epsilon])
            cylinder(d=12-epsilon,h=slip_ring_height+slip_ring_clearance);
        }
        rotate([0,0,18])
        translate([0,ring_outer_diam/2 - alignment_hole_offset,
                     slip_ring_height + slip_ring_clearance -
                     alignment_depth]) {
          translate([0,0,-epsilon])
            cylinder(d=alignment_hole_head_diam + 2*cl, h=10+epsilon);
          scale([1,1,-1])
            cylinder(d=alignment_hole_foot_diam + 2*cl,
                     h=2*alignment_depth);
        }
      }
    }
  }
}

module spinner_lid1(ring_outer_diam=ring_outer_diam(), slip_ring_height=17.3, clearance=clearance()) {
  ring_height = slip_ring_height + 3/*slip_ring_clearance*/;
  // alignment feature fits in the PCB cutout
  lid_thick = lid1_thick();
  pcb_size = pcb_size();
  standoff_offset = 4; // XXX copied from above
  screw_diam = screw_4_40_clearance();
  letter_deep = 0.75;
  epsilon = .1;
  cl = clearance;

  translate([0,0,ring_height]) {
    // alignment feature that fits into cutout in pcb
    translate([0,0,-1.6])
      cylinder(d=18.6 - 2*cl, h=1.6 /* pcb thickness */ + epsilon);
    difference() {
      // main lid
      cylinder(d=ring_outer_diam, h=lid_thick, $fn=10);
      // screw holes that line up with pcb mounting holes
      for (i=[1,-1]) for (j=[-1,1]) scale([i,j,1]) {
        translate([-pcb_size.x/2 + standoff_offset,
                   -pcb_size.y/2 + standoff_offset,
                   -epsilon]) {
          cylinder(d=screw_diam+2*cl, h=lid_thick+2*epsilon, $fn=48);
        }
      }
      // Z for zachary
      translate([0,0,lid_thick]) rotate([0*180,0,-1.5*36])
        linear_extrude(height=2*letter_deep, center=true)
        text(text="Z", size=25, halign="center", valign="center",
             font="Lato:style=Bold");
    }
  }
}

module spinner_lid2(ring_outer_diam=ring_outer_diam(), clearance=clearance()) {
  outer_wall_thick = lid2_wall_thick();
  lid_thick = lid2_thick();
  epsilon = .1;
  cl = clearance;
  difference() {
    // lid
    translate([0,0,-lid_thick])
      cylinder(d=ring_outer_diam, h=lid_thick, $fn=10);
    // screw holes to connect w/ ring
    spinner_lid2_screws(ring_outer_diam=ring_outer_diam,
                        d=screw_4_40_clearance());
    // hollow out a place for the power switch
    spinner_electronics(extra=clearance, pretty=false, labels=true);
  }
  difference() {
    union() {
      translate([0,0,-epsilon])
        cylinder(d=ring_outer_diam - 2*outer_wall_thick - 2*cl,
                 h=epsilon + 2, $fn=10);
      translate([23,-5,0])
       cube([5,10,3]);
      translate([10,-20.5,0])
       cube([10,41,3]);
    }
    difference() {
      union() {
        translate([0,0,-2*epsilon])
          cylinder(d=ring_outer_diam - 2*outer_wall_thick - 2*cl - 2*lid_thick,
                   h=2*epsilon + 10, $fn=10);
        for (i=[0:4]) rotate([0,0,i*36])
          cube([7.5,ring_outer_diam,10], center=true);
      }
      translate([4,0,0])
      cube([9,55,3*epsilon + 12], center=true);
      translate([12,0,0])
        cube([32,40,3*epsilon + 12], center=true);
    }
    spinner_electronics(extra=clearance, pretty=false, lid=true);
    spinner_lid2_screws(ring_outer_diam=ring_outer_diam,
                        d=lid2_screw_foot() + 2*cl);
  }
}

module spinner_lid2_screws(ring_outer_diam=ring_outer_diam(), d=screw_4_40_tap()) {
  outer_wall_thick = lid2_wall_thick();
  inset = -outer_wall_thick/2 + 2;
  num = 2;
  cheat = 18;
  pos = [0,90-cheat,180,270-cheat];
  //pos = [0,90,180,270];
  //pos = [0,120,240];
  for(p=pos) rotate([0,0,90 + p])
    translate([0,ring_outer_diam/2 - outer_wall_thick - inset,-10])
      cylinder(d=d, h=100);
}

module spinner_electronics(extra=0, slip_ring_height=17.3, extra_height=5, clearance=clearance(), pretty=false, labels=false, lid=false) {
  // copied from params for ring1c
  slip_ring_clearance = 3 + extra_height;
  total_thick = slip_ring_height + slip_ring_clearance;
  lid_thick = lid2_thick();
  z_letter_deep = 0.75;
  letter_deep = 0.4;
  epsilon = .1;
  cl = clearance;

  translate([0,0,20.3+5+15-29]) {
    // slip ring
    color("grey") cylinder(d=12.5+2*extra,h=29);
    %if (pretty)
      translate([0,0,-3]) cylinder(d=12.5+2*extra,h=3); // wiring area
  }
  translate([-16-extra,-51/2-extra,0]) rotate([0,0,0]) {
    usb_extra = lid ? 13 : 0;
    // feather 328p
    color("blue") cube([23+2*extra,51+2*extra,pretty ? 1.6 : (8+extra)]);
    color("grey") translate([23/2-9/2,-usb_extra,0]) // usb connector
      cube([9+2*extra,7+usb_extra+2*extra,4.3+1.6+extra]);
    %if (pretty)
      translate([0,0,1.6]) cube([23,51,8-1.6]);
    // mounting screws
    translate([23/2 + extra, 51/2 + extra, -lid_thick-epsilon]) {
      for (j=[1,-1]) {
        if (j<0) translate([j*0.7*inch()/2,-1.8*inch()/2,0])
          cylinder(d=0.1*inch()+2*cl, h = lid_thick + 8 + 2*epsilon);
        translate([j*0.75*inch()/2,1.8*inch()/2,0])
          cylinder(d=0.09*inch()+2*cl, h = lid_thick + 8 + 2*epsilon);
      }
    }
  }
  translate([-2.5-extra,-36/2-extra,1.6])
    // battery (attach to the lid w/ double-sided tape)
    color("red") cube([29+2*extra,36+2*extra,4.75+extra]);
  // 5V power boost for LEDs
  translate([0,-23,total_thick-1.7/*pcb_thick*/-21.65])
  rotate([0,-90,-90]) translate([-2*extra,-28.3/2-extra,-5.4-extra]) {
    color("purple") cube([21.65+10*extra,28.3+2*extra,5.4/*7 w/ JST*/+2*extra]);
    // JST connector
    translate([21.65/2-(extra>0?10:0),28.3-8.1,5.4-7])
      cube([8+2*extra+(extra>0?10:0),8.1+2*extra,7+2*extra]);
  }
  // switch button is 2.6mm tall unpressed, 1mm pressed. So 0.6mm of lid
  // thickness should be fine.
  switch_inset = 0.6;
  rotate([0,0,-1.5 * 36]) translate([0,-30.5,-lid_thick+switch_inset]) {
    rotate([0,0,-8]) {
    // power switch
    color("green") translate([-6-extra,-6-extra,0])
      cube([12+2*extra,12+2*extra,6.8+extra]);
    translate([0,0,-2.6-10*extra])
    color("red") cylinder(d=5.4+2*extra, h=2.6+10*extra+epsilon);
    }
    if (labels && false) {
    translate([0,4.5,-switch_inset]) rotate([180,0,0])
    linear_extrude(height=2*letter_deep, center=true)
    text(text="POWER", size=3, halign="center", valign="top",
         font="Lato:style=Bold");
    }
  }
  // screw holes for panel mount usb jack
  translate([-23.5,7.5,-lid_thick-epsilon]) rotate([0,0,-18]) {
    jack_height = 5 + extra;
    if (!pretty) for (i=[1,-1]) translate([0,9*i,0])
      cylinder(d=screw_4_40_clearance() + 2*cl, h=lid_thick+2*epsilon);
    color("brown") {
      cube([4.3+cl*2,9+cl*2,2*(lid_thick+2*epsilon)], center=true);
      // jack cutout depth is really 0.8, but we'll use 1mm for extra strength
      translate([0,0,1/*jack cutout depth*/+epsilon]) {
        translate([0,0,jack_height/2])
          cube([7.8+extra,24.9+extra,jack_height], center=true);
        translate([0,0,25.6/2 + extra/2])
          cube([9.9+extra,11.25+extra,25.6 + extra], center=true);
        if (extra>0) // XXX is this cutout necessary?
          translate([0,-(11.25+2*extra)/2,10])
          cube([20,11.25+2*extra,30]);
      }
    }
    if (labels && false) {
      translate([-4,0,epsilon]) rotate([180,0,-90])
      linear_extrude(height=2*letter_deep, center=true)
      text(text="CHARGE", size=3, halign="center", valign="bottom",
           font="Lato:style=Bold");
    }
  }
  // charge status LED (T-1, 3mm)
  translate([16.75,-21.1,-lid_thick-0.6]) {
    cylinder(d=4.4+2*cl, h=4.8);
    translate([0,0,2.4-cl]) cylinder(d=5.15+2*cl, h=2.4+1/*extra*/);
  }
  // Z for zachary
  if (labels) {
    translate([0,0,-lid_thick]) rotate([180,0,-1.5*36])
      linear_extrude(height=2*z_letter_deep, center=true)
      text(text="Z", size=25, halign="center", valign="center",
           font="Lato:style=Bold");
  }
  // snap brackets for power switch?
}
