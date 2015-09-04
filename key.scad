// Render precision
// Set this to a small value for fast renders
$fn = 700;

// Radius of the cylinder used to round the edges of the top and bottom bases
base_radius = 1.5;

// Angle measured on the HHKB
keyboard_angle = 7.3;

// Basic key characteristics
key_thickness = 1.4;
top_base_extrusion_height = 0.01;
bottom_base_extrusion_height = 0.01;

// Key size
key_size = 1;

// Connector dimensions
connector_radius = 2.85;
connector_height = -1.35;
connector_thickness = 1;
connector_support_height = 4;
connector_middle_space = 1.5;

//11.6

// Dimension fields:
// 0: top_base_height_back
// 1: top_base_height_front
// 2: top_base_rotated_length
// 3: top_base_width

// Topre dimensions
row_dimensions = [
	[10.4, 1], // Row E (default: [10.3, 1])
	[8.2, -2], // Row D (default: [8, -4])
	[7, -6], // Row C (default: [7, -6])
	[6.7, -13], // Row B (default: [6.7, -14])
	[6.7, -13], // Row A (default: [6.7, -14])
];

// Dimensions that are relevant to all rows
key_dimensions = [
	0.6, // Top base sagitta (default: 0.6)
	11.5, // Top base width
	18, // Bottom base length
	18, // Bottom base width
	66, // Bottom base angle
];

// Some rendering options
apply_keyboard_angle = 1;
apply_key_angle = 1;
apply_cylindrical_dish = 1;

// Key dimensions
top_base_sagitta = apply_cylindrical_dish ? key_dimensions[0] : 0;
top_base_width = key_dimensions[1] * key_size;
bottom_base_length = key_dimensions[2];
bottom_base_width = key_dimensions[3] - key_dimensions[1] + key_dimensions[1] * key_size;
bottom_base_angle = key_dimensions[4];

// Calculate key angle based on top_base_height_front
//top_base_height_front = 10.15;
//top_base_angle = atan((top_base_height_back - top_base_height_front)/(bottom_base_length - top_base_height_back/tan(bottom_base_angle)));

// Calculation for the side angle
bottom_base_side_angle = atan(top_base_height_back/((top_base_width - bottom_base_width) / 2));

// Functions used to calculate dimensions of the cylindrical dish
function sagitta(radius, chord) = radius - pow(pow(radius, 2) - pow(chord/2, 2), 0.5);
function central_chord(chord, sagitta) = pow(chord/2, 2)/sagitta;
function cylinder_radius(chord, sagitta) = (central_chord(chord, sagitta) + sagitta)/2;

// Generates the bases of the key using the minkowski function
// width: width of the base
// length: length of the base
// extrusion: extrusion height used to generate the height of the base
module base(width, length, extrusion) {
		minkowski() {
			cube([width - 2 * base_radius, length - 2 * base_radius, extrusion/2]);

			translate([base_radius, base_radius, 0]) 
				cylinder(h=extrusion/2, r=base_radius);
		}
}

// Generates the cylindrical dish
module dish_cylinder(top_base_rotated_length, rotated_cylinder_translate, cylinder_dish_radius, top_base_sagitta, back_cylinder_translate) {
	translate([0, top_base_rotated_length + rotated_cylinder_translate, cylinder_dish_radius - top_base_sagitta])
	rotate([90,0,0])
		cylinder(h=top_base_rotated_length + rotated_cylinder_translate + back_cylinder_translate, r=cylinder_dish_radius);
}

// Basic function that generates the key
module key(row) {
	// Row dimensions
	key_row_dimensions = row_dimensions[row];
	top_base_height_back = key_row_dimensions[0];
	top_base_angle = apply_key_angle ? key_row_dimensions[1] : 0;

	// Calculations for the top base
	top_base_length = (bottom_base_length * tan(bottom_base_angle) - top_base_height_back)/(tan(bottom_base_angle) - tan(top_base_angle));
	top_base_height_front = top_base_height_back - top_base_length * tan(top_base_angle);
	top_base_rotated_length = top_base_length/cos(top_base_angle);
	cylinder_dish_radius = cylinder_radius(top_base_width, top_base_sagitta);
	rotated_cylinder_translate = top_base_sagitta/tan(bottom_base_angle-top_base_angle);
	back_cylinder_translate = (top_base_angle < 0) ? top_base_sagitta * tan(-top_base_angle) : 0;

	// Calculations for the internal walls
	//TODO Simplify this code
	internal_top_base_height_back = top_base_height_back - key_thickness;
	internal_base_difference = key_thickness/sin(bottom_base_angle);
	internal_bottom_base_width = bottom_base_width - 2 * internal_base_difference;
	internal_bottom_base_length = bottom_base_length - key_thickness - internal_base_difference;
	internal_top_base_rotated_difference = (top_base_height_back - internal_top_base_height_back)/tan(bottom_base_angle);
	internal_top_base_width = top_base_width - 2 * internal_base_difference + 2 * internal_top_base_rotated_difference;
	internal_top_base_length = top_base_length - key_thickness - internal_base_difference + 2 * internal_top_base_rotated_difference;
	internal_top_base_rotated_length = top_base_rotated_length - key_thickness - internal_base_difference + internal_top_base_rotated_difference;

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

			translate([bottom_base_width/2, bottom_base_length/2, connector_height])
				connector(top_base_height_back);
		}

		if (cylinder_dish_radius != 0) {
			translate([bottom_base_width/2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				dish_cylinder(top_base_rotated_length, rotated_cylinder_translate, cylinder_dish_radius, top_base_sagitta, back_cylinder_translate);
		}

		else {
			translate([(bottom_base_width - top_base_width)/2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				cube([top_base_width, top_base_rotated_length, top_base_height_back]);
		}
	}
}

// Generates the connector for the key
module connector(top_base_height_back) {
	sagitta_difference = sagitta(connector_radius, connector_thickness);

	union() {
		difference() {
			cylinder(h=top_base_height_back - connector_height, r = connector_radius);
			cylinder(h=top_base_height_back - connector_height, r = connector_radius - connector_thickness);

			translate([-connector_middle_space/2, -connector_radius, 0])
				cube([connector_middle_space, 2 * connector_radius, top_base_height_back - connector_height - connector_support_height]);
		}
	}
}

module connector_test() {
	translate([0, 0, top_base_height_back - connector_height])
		base(top_base_width, top_base_rotated_length, key_thickness);

	translate([top_base_width/2, top_base_length/2, 0])
		connector();
}

//connector_test();
key(3);