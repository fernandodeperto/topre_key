 $fn = 360;

//TODO put some text on the bottom of the keycap, like version

base_radius = 1.5;

bottom_base_length = 18.10;
bottom_base_width = 18.10;
bottom_base_angle = 69.78;

top_base_height_back = 9.39;
top_base_height_front = 8.39;
top_base_width = 12.37;

top_base_extrusion_height = .001;
bottom_base_extrusion_height = .5;

key_thickness = 1.4;

cylinder_dish_radius = 80;

connector_dimensions = [4.1, 1.35];
connector_radius = 2.77;
connector_height = 2;

support_height = 1.5;
support_depth = 0.5;

dcs_profile_angles = [-6, -1, 3, 7, 16, 16];

// Calculated stuff
top_base_length = bottom_base_length - top_base_height_front/tan(bottom_base_angle);
top_base_angle = atan((top_base_height_back-top_base_height_front)/top_base_length);
top_base_rotated_length = top_base_length/cos(top_base_angle);
key_scale = (bottom_base_width - 2 * key_thickness) / bottom_base_width;

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

module base(width, length, extrusion) {
		minkowski() {
			cube([width - 2 * base_radius, length - 2 * base_radius, extrusion/2]);

			translate([base_radius, base_radius, 0]) 
				cylinder(h=extrusion/2, r=base_radius);
		}
}

module key_shape() {
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

		if (cylinder_dish_radius != 0) {
			translate([bottom_base_width/2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
			translate([0, top_base_rotated_length + rotated_cylinder_translate, cylinder_dish_radius - dish_translate_distance])
			rotate([90,0,0])
				cylinder(h=top_base_rotated_length + rotated_cylinder_translate, r=cylinder_dish_radius);
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

module support() {
	base_difference = support_height/tan(bottom_base_angle);

	difference() {
		union() {
			translate([-(top_base_width + 2 * base_difference)/2, support_depth/2, 0])
			rotate([90, 0, 0])
			linear_extrude(height = support_depth)
				polygon([[0, 0], [top_base_width + 2 * base_difference, 0], [top_base_width + base_difference, support_height], [base_difference, support_height]]);

			translate([-support_depth/2, -(bottom_base_width)/2, 0])
			rotate([90, 0, 90])
			linear_extrude(height = support_depth)
				polygon([[0, 0], [top_base_length + base_difference, 0], [top_base_length, support_height], [0, support_height]]);
		}

		cylinder(h=support_height, r = connector_radius);
	}
}

module key() {
	key_shape();

	translate([bottom_base_width/2, bottom_base_width/2, connector_height])
		connector();

	translate([bottom_base_width/2, bottom_base_width/2, top_base_height_back - support_height - dish_translate_distance])
		*support();
}

key();
//connector_base();
