 $fn = 400;

// Radius of the cylinder used to round the edges of the top and bottom bases
base_radius = 1.5;

key_thickness = 1.2;
top_base_extrusion_height = 0.01;
bottom_base_extrusion_height = 0.01;

// Connector
connector_radius = 2.94;
connector_height = -0.57;
connector_thickness = 1.2;
connector_support_height = 4;
connector_middle_space = 1.5;

// Text
text_size = 2;
text_extrusion_height = 1.4;

// Dimension fields:
// 0: top_base_height_back
// 1: top_base_height_front
// 2: top_base_rotated_length
// 3: top_base_width

// Topre dimensions
row_dimensions = [
	[10.4, 10, 13.7, 11.5], // Row E
	[8, 8.7, 13.74, 11.7], // Row D
	[7.1, 8.34, 14, 11.9], // Row C
	[6.7, 10, 13.6, 11.8], // Row B
];

key_dimensions = [
	0.5, // Top base sagitta
	0, // Cylinder dish radius
	18, // Bottom base length
	18, // Bottom base width
];

key_row_dimensions = row_dimensions[0];

top_base_height_back = key_row_dimensions[0];
top_base_height_front = key_row_dimensions[1];
top_base_rotated_length = key_row_dimensions[2];
top_base_width = key_row_dimensions[3];
key_row_label = key_row_dimensions[4];
top_base_sagitta = key_dimensions[0];
bottom_base_length = key_dimensions[2];
bottom_base_width = key_dimensions[3];

//cylinder_dish_radius = 0;
cylinder_dish_radius = cylinder_radius(top_base_width, top_base_sagitta);

// Calculated stuff

top_base_length = pow(pow(top_base_rotated_length, 2) - pow(top_base_height_back - top_base_height_front, 2), 0.5);
top_base_angle = atan((top_base_height_back-top_base_height_front)/top_base_length);
bottom_base_angle = atan(top_base_height_front / (bottom_base_length - top_base_length));
//top_base_rotated_length = top_base_length/cos(top_base_angle);

// No dish translate distance if no dish is being used
dish_translate_distance = (cylinder_dish_radius != 0) ? sagitta(cylinder_dish_radius, top_base_width) : 0;
rotated_cylinder_translate = dish_translate_distance/tan(bottom_base_angle-top_base_angle);
back_cylinder_translate = (top_base_angle < 0) ? dish_translate_distance * tan(-top_base_angle) : 0;

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

module dish_cylinder() {
	translate([0, top_base_rotated_length + rotated_cylinder_translate, cylinder_dish_radius - dish_translate_distance])
	rotate([90,0,0])
		cylinder(h=top_base_rotated_length + rotated_cylinder_translate + back_cylinder_translate, r=cylinder_dish_radius);
}

module key() {
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

			translate([bottom_base_width/2, bottom_base_width/2, connector_height])
				connector();

			//translate([0, 0, internal_top_base_height_back])
			//rotate([-top_base_angle, 0, 0])
			//translate([bottom_base_width/2, bottom_base_length/6, 0])
			//rotate([0, 0, 180])
				//_text(key_row_label);

		}

		if (cylinder_dish_radius != 0) {
			translate([bottom_base_width/2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				dish_cylinder();
		}

		else {
			translate([(bottom_base_width - top_base_width)/2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				cube([top_base_width, top_base_rotated_length, top_base_height_back]);
		}
	}
}

module connector_test() {
	translate([0, 0, top_base_height_back])
		base(top_base_width, top_base_rotated_length, 1.2);

	translate([top_base_width/2, top_base_length/2, connector_height])
		connector();
}

module connector() {
	sagitta_difference = sagitta(connector_radius, connector_thickness);

	union() {
		difference() {
			cylinder(h=top_base_height_back - connector_height, r = connector_radius);
			cylinder(h=top_base_height_back - connector_height, r = connector_radius - connector_thickness);

			translate([-connector_middle_space/2, -connector_radius, 0])
				cube([connector_middle_space, 2 * connector_radius, top_base_height_back - connector_height]);
		}

		translate([-connector_radius + sagitta_difference, -connector_thickness/2, top_base_height_back - connector_height - connector_support_height])
			cube([2 * connector_radius - 2 * sagitta_difference, connector_thickness, connector_support_height]);
	}
}

module _text(string) {
	translate([0, -text_size/2, 0])
	rotate([0, 180, 0])
	linear_extrude(height=text_extrusion_height)
		text(text=string, size=text_size, halign="center");
}

key();