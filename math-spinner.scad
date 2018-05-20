/* Electronic Math Spinner */

/* [Global] */

// Which part.
part = "all"; // [ring1a, ring1b, ring1c, ring2, ring3, insert, lid1, lid2]

/* [Hidden] */
function ring_outer_diam() = 80;
function neopixel_led_height() = 8.7 - 1.0/*shoulder*/;
function lid2_thick() = 1.5;
function clearance() = 0.25;

rotate([0,-90,0])
spinner_part(which=part);

module spinner_part(which="all") {
  if (which=="all") {
    spacing=21;
    translate([0,0,0*spacing - 4]) {
      spinner_part("ring1c");
      translate([0,0,-.5])
        spinner_part("lid2");
    }
    translate([0,0,1*spacing]) {
      spinner_part("ring1b");
    }
    translate([0,0,2*spacing]) {
      spinner_part("ring3");
    }
    translate([0,0,3*spacing]) {
      spinner_part("ring1b");
    }
    translate([0,0,4*spacing]) {
      spinner_part("ring2");
    }
    translate([0,0,5*spacing]) {
      spinner_part("ring1a");
      spinner_part("lid1");
    }
  }
  if (which=="insert") {
    spinner_insert();
  }
  if (which=="ring") {
    spinner_ring();
  }
  if (which=="ring1a") {
    // two variants: one with no_led = true, and one with
    // no_switch=true (which would hollow out a space for electronics)
    spinner_ring(label="0123456789");
  }
  if (which=="ring1b") {
    // internal ring.
    spinner_ring(label="0123456789", no_led=true);
  }
  if (which=="ring1c") {
    spinner_ring(label="0123456789", no_led=true, no_switch=true, extra_height=6-lid2_thick());
  }
  if (which=="ring2") {
    spinner_ring(label="0+−×÷+−×÷+−", no_led=true);
  }
  if (which=="ring3") {
    spinner_ring(label="0=>=<=>=<=>=<=", no_led=true);
  }
  if (which=="lid1") {
    spinner_lid1(); // lid for ring1a
  }
  if (which=="lid2") {
    spinner_lid2(); // lid for ring1c
  }
  if (which=="ring-test") {
    intersection() {
      spinner_ring(no_feet=true);
      cylinder(d=32, h=100, $fn=10);
    }
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
  pcb_size = 35; // mm sq
  standoff_offset = 5;
  standoff_screw_diam = 2;
  standoff_screw_depth = 10;
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
        cylinder(d=sqrt(2)*pcb_size+2*cl, h=1+epsilon);
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
          translate([-pcb_size/2, -pcb_size/2, 0])
            cube([pcb_size, pcb_size, pcb_clearance + epsilon]);
          if (!no_feet) for (i=[1,-1]) for (j=[-1,1]) scale([i,j,1])
            translate([-pcb_size/2 + standoff_offset,
                       -pcb_size/2 + standoff_offset,
                       -epsilon]) {
              cylinder(d=standoff_foot_diam, h=pcb_clearance-pcb_thick+epsilon);
            }
        }
      }
      // screw holes for pcb feet
      for (i=[1,-1]) for (j=[-1,1]) scale([i,j,1])
        translate([-pcb_size/2 + standoff_offset,
                   -pcb_size/2 + standoff_offset,
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
              translate([0,0,-10.5]) rotate([-90,0,0])
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
        led_height = neopixel_led_height();
        bottom_wall_thick = 2;
        outer_wall_thick = led_height;
        alignment_depth = 20;
        difference() {
          union() {
            translate([0,0,-epsilon])
              cylinder(d=ring_outer_diam - 2*outer_wall_thick,
                       h=slip_ring_height+slip_ring_clearance+epsilon
                       - pcb_clearance - bottom_wall_thick,
                       $fn=10);
          }
          rotate([0,0,18])
          translate([0,ring_outer_diam/2 - alignment_hole_offset,
                     epsilon + (slip_ring_height + slip_ring_clearance)
                     -alignment_depth])
            cylinder(d=10, h=100);
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

module spinner_lid1() {
}

module spinner_lid2(ring_outer_diam=ring_outer_diam(), clearance=clearance()) {
  led_height = neopixel_led_height();
  outer_wall_thick = led_height;
  lid_thick = lid2_thick();
  epsilon = .1;
  cl = clearance;
  translate([0,0,-lid_thick])
    cylinder(d=ring_outer_diam, h=lid_thick, $fn=10);
  difference() {
    translate([0,0,-epsilon])
      cylinder(d=ring_outer_diam - 2*outer_wall_thick - 2*cl,
               h=epsilon + 2, $fn=10);
    translate([0,0,-2*epsilon])
      cylinder(d=ring_outer_diam - 2*outer_wall_thick - 2*cl - 2*lid_thick,
               h=2*epsilon + 10, $fn=10);
    for (i=[0:4]) rotate([0,0,i*36])
      cube([7,ring_outer_diam,10], center=true);
  }
  // XXX add screw holes
}
