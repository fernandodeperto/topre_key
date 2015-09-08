// Functions used to calculate dimensions of the cylindrical dish
function sagitta(radius, chord) = radius - pow(pow(radius, 2) - pow(chord/2, 2), 0.5);
function central_chord(chord, sagitta) = pow(chord/2, 2)/sagitta;
function cylinder_radius(chord, sagitta) = (central_chord(chord, sagitta) + sagitta)/2;

// Generates the bases of the key using the minkowski function
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

// Basic key shape
module key_shape(top_base_translate, top_base_height_back, top_base_angle, top_base_rotated_length) {
	hull() {
		base(bottom_base_width, bottom_base_length, bottom_base_extrusion_height);

		translate([(bottom_base_width-top_base_width)/2, top_base_translate, top_base_height_back - top_base_extrusion_height])
			rotate([-top_base_angle, 0, 0])
			base(top_base_width, top_base_rotated_length, top_base_extrusion_height);
	}
}

// Basic function that generates the key
module key(row) {
	// Row dimensions
	key_row_dimensions = row_dimensions[row];
	top_base_height_back = key_row_dimensions[0];
	top_base_angle = apply_key_angle ? key_row_dimensions[2] : 0;
	top_base_translate = top_base_height_back/tan(bottom_base_angle_back);
	bottom_base_angle_front = key_row_dimensions[1];

	// Calculations for the top base
	top_base_length = (bottom_base_length * tan(bottom_base_angle_front) - top_base_height_back)/(tan(bottom_base_angle_front) - tan(top_base_angle));
	top_base_height_front = top_base_height_back - top_base_length * tan(top_base_angle);
	top_base_rotated_length = top_base_length/cos(top_base_angle);
	cylinder_dish_radius = cylinder_radius(top_base_width, top_base_sagitta);
	rotated_cylinder_translate = top_base_sagitta/tan(bottom_base_angle_front-top_base_angle);
	back_cylinder_translate = top_base_sagitta/tan(bottom_base_angle_back+top_base_angle);

	key_scale = (bottom_base_width - 2 * key_thickness) / bottom_base_width;

	difference() {
		union() {
			difference() {
				key_shape(top_base_translate, top_base_height_back, top_base_angle, top_base_rotated_length);

				translate([key_thickness, key_thickness, 0])
				scale(key_scale)
					key_shape(top_base_translate, top_base_height_back, top_base_angle, top_base_rotated_length);

			}

			translate([bottom_base_width/2, bottom_base_length/2, connector_height])
				connector(top_base_height_back);
		}

		if (apply_cylindrical_dish) {
			translate([bottom_base_width/2, top_base_translate, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				dish_cylinder(top_base_rotated_length, rotated_cylinder_translate, cylinder_dish_radius, top_base_sagitta, back_cylinder_translate);
		}

		else {
			translate([(bottom_base_width - top_base_width)/2, top_base_translate , top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				cube([top_base_width, top_base_rotated_length, top_base_height_back]);
		}
	}

	if (apply_symbol) {
		translate([0, 0, top_base_height_back])
		rotate([-top_base_angle, 0, 0])
		translate([bottom_base_width/2, top_base_rotated_length/2 + top_base_translate, 0])
			symbol(top_base_rotated_length);
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

module symbol(top_base_rotated_length) {
	symbol_initial_width = dxf_dim(file=symbol_path, name="total_width");
	symbol_initial_length = dxf_dim(file=symbol_path, name="total_height");

	symbol_width_scale = (top_base_width - symbol_spacing)/symbol_initial_width;
	symbol_length_scale = (top_base_rotated_length - symbol_spacing)/symbol_initial_length;
	symbol_scale = min(symbol_width_scale, symbol_length_scale);
	symbol_width = symbol_initial_width * symbol_scale;
	symbol_length = symbol_initial_length * symbol_scale;

	//color("blue")
	//translate([-symbol_width/2, -symbol_length/2, 0])
	//	cube([symbol_width, symbol_length, 0.1]);

	color("orange")
	translate([symbol_width/2, symbol_length/2, 0])
	scale([symbol_scale, symbol_scale, 1])
	rotate([0, 0, 180])
	linear_extrude(height=symbol_thickness)
		import(file=symbol_path);
}
