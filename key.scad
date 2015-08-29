 $fn = 200;

//TODO put some text on the bottom of the keycap, like version

// Radius of the cylinder used to round the edges of the top and bottom bases
base_radius = 1.5;

bottom_base_length = 18.8;
bottom_base_width = 18.8;

top_base_height_back = 10;
// Valor original: 9.8
top_base_height_front = 9;
top_base_sagitta = 0.3;
top_base_width = 11.5;
top_base_rotated_length = 13.4;

//cylinder_dish_radius = 0;
cylinder_dish_radius = cylinder_radius(top_base_width, top_base_sagitta);

top_base_extrusion_height = 0.25;
bottom_base_extrusion_height = 1.2;

key_thickness = 1.2;

// Cherry MX connector
connector_dimensions = [4.1, 1.35];
connector_radius = 2.77;
connector_height = -1.3;
connector_thickness = 0.72;

// Topre connector
topre_connector_radius = 2.96;
topre_connector_height = -0.57;
topre_connector_thickness = 1.24;

// Topre key dimensions for each row
//TODO

//TODO Implement this part
keyboard_angle = 0;

// Calculated stuff
top_base_length = pow(pow(top_base_rotated_length, 2) - pow(top_base_sagitta, 2), 0.5);
//top_base_rotated_length = top_base_length/cos(top_base_angle);
bottom_base_angle = atan(top_base_height_front / (bottom_base_length - top_base_length));
top_base_angle = atan((top_base_height_back-top_base_height_front)/top_base_length);

// No dish translate distance if no dish is being used
dish_translate_distance = (cylinder_dish_radius != 0) ? sagitta(cylinder_dish_radius, top_base_width) : 0;
rotated_cylinder_translate = dish_translate_distance/tan(bottom_base_angle-top_base_angle);

// Calculations for the internal walls
internal_top_base_height_back = top_base_height_back - key_thickness;
internal_base_difference = key_thickness/sin(bottom_base_angle);
internal_bottom_base_width = bottom_base_width - 2 * internal_base_difference;
internal_bottom_base_length = bottom_base_length - key_thickness - internal_base_difference;
internal_top_base_rotated_difference = (top_base_height_back - internal_top_base_height_back)/tan(bottom_base_angle);
internal_top_base_width = top_base_width - 2 * internal_base_difference + 2 * internal_top_base_rotated_difference;
internal_top_base_length = top_base_length - key_thickness - internal_base_difference + 2 * internal_top_base_rotated_difference;
internal_top_base_rotated_length = top_base_rotated_length - key_thickness - internal_base_difference + internal_top_base_rotated_difference;

function sagitta(radius, chord) = radius - pow(pow(radius, 2) - pow(chord/2, 2), 0.5);
function central_chord(chord, sagitta) = pow(chord/2, 2)/sagitta;
function cylinder_radius(chord, sagitta) = (central_chord(chord, sagitta) + sagitta)/2;

module base(width, length, extrusion) {
		minkowski() {
			cube([width - 2 * base_radius, length - 2 * base_radius, extrusion/2]);

			translate([base_radius, base_radius, 0]) 
				cylinder(h=extrusion/2, r=base_radius);
		}
}

module key_shape() {
	difference() {
		union() {
			difference() {
				hull() {
					base(bottom_base_width, bottom_base_length, bottom_base_extrusion_height);

					translate([(bottom_base_width-top_base_width)/2, 0, top_base_height_back - top_base_extrusion_height])
					rotate([-top_base_angle, 0, 0])
						base(top_base_width, top_base_rotated_length, top_base_extrusion_height);
				}

				hull() {
					translate([(bottom_base_width - internal_bottom_base_width)/2, (bottom_base_length - internal_bottom_base_length)/2, 0])
						base(internal_bottom_base_width, internal_bottom_base_length, bottom_base_extrusion_height);

					translate([(bottom_base_width-top_base_width)/2 + (top_base_width-internal_top_base_width)/2, key_thickness, internal_top_base_height_back - top_base_extrusion_height])
					rotate([-top_base_angle, 0, 0])
						base(internal_top_base_width, internal_top_base_rotated_length, top_base_extrusion_height);
				}
			}

			translate([bottom_base_width/2, bottom_base_width/2, topre_connector_height])
				connector_topre();
		}

		if (cylinder_dish_radius != 0) {
			translate([bottom_base_width/2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
			translate([0, top_base_rotated_length + rotated_cylinder_translate, cylinder_dish_radius - dish_translate_distance])
			rotate([90,0,0])
				cylinder(h=top_base_rotated_length + rotated_cylinder_translate, r=cylinder_dish_radius);
		}

		else {
			translate([(bottom_base_width - top_base_width)/2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				cube([top_base_width, top_base_rotated_length, top_base_height_back]);
		}
	}
}

module connector() {
	difference() {
		cylinder(h = internal_top_base_height_back - connector_height, r = connector_radius);

		translate([-connector_dimensions[0]/2, -connector_dimensions[1]/2, 0])
			cube([connector_dimensions[0], connector_dimensions[1], top_base_height_back - connector_height], false);

		rotate([0, 0, 90])
		translate([-connector_dimensions[0]/2, -connector_dimensions[1]/2, 0])
			cube([connector_dimensions[0], connector_dimensions[1], top_base_height_back - connector_height], false);

		translate([-internal_top_base_width/2, -internal_bottom_base_length/2, internal_top_base_height_back - connector_height])
		rotate([-top_base_angle, 0])
			cube([internal_top_base_width, internal_top_base_rotated_length, internal_top_base_height_back]);
	}
}

module connector2() {
	difference() {
		union() {
			translate([0, 0, (top_base_height_back - connector_height)/2])
				cube([connector_dimensions[1] + 2 * connector_thickness, connector_dimensions[0] + 2 * connector_thickness, top_base_height_back - connector_height], true);

			translate([0, 0, (top_base_height_back - connector_height)/2])
			rotate([0, 0, 90])
				cube([connector_dimensions[1] + 2 * connector_thickness, connector_dimensions[0] + 2 * connector_thickness, top_base_height_back - connector_height], true);
		}

		union() {
			translate([0, 0, (top_base_height_back - connector_height)/2])
				cube([connector_dimensions[1], connector_dimensions[0], top_base_height_back - connector_height], true);

			translate([0, 0, (top_base_height_back - connector_height)/2])
			rotate([0, 0, 90])
				cube([connector_dimensions[1], connector_dimensions[0], top_base_height_back - connector_height], true);
		}
	}
}

module connector_topre() {
	sagitta_difference = sagitta(topre_connector_radius, topre_connector_thickness);

	union() {
		difference() {
			cylinder(h=top_base_height_back - topre_connector_height, r = topre_connector_radius);
			cylinder(h=top_base_height_back - topre_connector_height, r = topre_connector_radius - topre_connector_thickness);

			translate([-topre_connector_thickness/2, -topre_connector_radius, 0])
				cube([topre_connector_thickness, 2 * topre_connector_radius, top_base_height_back - topre_connector_height]);
		}

		translate([-topre_connector_radius + sagitta_difference, -topre_connector_thickness/2, 0])
			cube([2 * topre_connector_radius - 2 * sagitta_difference, topre_connector_thickness, top_base_height_back - topre_connector_height]);
	}
}

module key() {
	key_shape();

	translate([bottom_base_width/2, bottom_base_width/2, topre_connector_height])
		connector_topre();
}

key_shape();
