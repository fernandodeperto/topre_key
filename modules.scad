// Key dimensions
top_base_sagitta = APPLY_CYLINDRICAL_DISH ? KEY_DIMENSIONS[0] : 0;
top_base_width = KEY_DIMENSIONS[1] * KEY_SIZE;
bottom_base_length = KEY_DIMENSIONS[2];
bottom_base_width = KEY_DIMENSIONS[3] - KEY_DIMENSIONS[1] + KEY_DIMENSIONS[1] * KEY_SIZE;
bottom_base_angle_back = KEY_DIMENSIONS[4];

// Functions used to calculate dimensions of the cylindrical dish
function sagitta(radius, chord) = radius - pow(pow(radius, 2) - pow(chord/2, 2), 0.5);
function central_chord(chord, sagitta) = pow(chord/2, 2)/sagitta;
function cylinder_radius(chord, sagitta) = (central_chord(chord, sagitta) + sagitta)/2;

// Generates the bases of the key using the minkowski function
module base(width, length, extrusion) {
		minkowski() {
			cube([width - 2 * BASE_RADIUS, length - 2 * BASE_RADIUS, extrusion/2]);

			translate([BASE_RADIUS, BASE_RADIUS, 0])
				cylinder(h=extrusion/2, r=BASE_RADIUS);
		}
}

// Generates the cylindrical dish
module dish_cylinder(top_base_rotated_length, rotated_cylinder_translate, cylinder_dish_radius, top_base_sagitta, back_cylinder_translate) {
	translate([0, top_base_rotated_length + rotated_cylinder_translate, cylinder_dish_radius - top_base_sagitta])
	rotate([90,0,0])
		cylinder(h=top_base_rotated_length + rotated_cylinder_translate + back_cylinder_translate, r=cylinder_dish_radius);
}

// Basic key shape
module key_shape(top_base_translate, top_base_height_back, top_base_angle, top_base_rotated_length, back_cylinder_translate, rotated_cylinder_translate, cylinder_dish_radius) {
	difference() {
		hull() {
			base(bottom_base_width, bottom_base_length, BOTTOM_BASE_EXTRUSION_HEIGHT);

			translate([(bottom_base_width-top_base_width)/2, top_base_translate, top_base_height_back - TOP_BASE_EXTRUSION_HEIGHT])
			rotate([-top_base_angle, 0, 0])
				base(top_base_width, top_base_rotated_length, TOP_BASE_EXTRUSION_HEIGHT);
		}

		if (APPLY_CYLINDRICAL_DISH) {
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
}

// Basic function that generates the key
module key(row, symbol_number) {
	// Row dimensions
	KEY_ROW_DIMENSIONS = ROW_DIMENSIONS[row];
	top_base_height_back = KEY_ROW_DIMENSIONS[0];
	top_base_angle = APPLY_KEY_ANGLE ? KEY_ROW_DIMENSIONS[2] : 0;
	top_base_translate = top_base_height_back/tan(bottom_base_angle_back);
	bottom_base_angle_front = KEY_ROW_DIMENSIONS[1];

	// Calculations for the top base
	top_base_length = (bottom_base_length * tan(bottom_base_angle_front) - top_base_height_back)/(tan(bottom_base_angle_front) - tan(top_base_angle));
	top_base_height_front = top_base_height_back - top_base_length * tan(top_base_angle);
	top_base_rotated_length = top_base_length/cos(top_base_angle);
	cylinder_dish_radius = cylinder_radius(top_base_width, top_base_sagitta);
	rotated_cylinder_translate = top_base_sagitta/tan(bottom_base_angle_front-top_base_angle);
	back_cylinder_translate = top_base_sagitta/tan(bottom_base_angle_back+top_base_angle);

	// Scale to generate the internal part of the key
	key_scale = (bottom_base_width - 2 * KEY_THICKNESS) / bottom_base_width;

	// Side angle used for the support
	bottom_base_angle_side = atan(top_base_height_back/((bottom_base_width-top_base_width)/2));

	difference() {
		union() {
			difference() {
				key_shape(top_base_translate, top_base_height_back, top_base_angle, top_base_rotated_length, back_cylinder_translate, rotated_cylinder_translate, cylinder_dish_radius);

				translate([KEY_THICKNESS, KEY_THICKNESS, 0])
				scale(key_scale)
					key_shape(top_base_translate, top_base_height_back, top_base_angle, top_base_rotated_length, back_cylinder_translate, rotated_cylinder_translate, cylinder_dish_radius);


			}

			difference() {
				translate([bottom_base_width/2, bottom_base_length/2, CONNECTOR_HEIGHT])
					connector(max(top_base_height_front, top_base_height_back));

				if (APPLY_CYLINDRICAL_DISH) {
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
		}
	}

	if (APPLY_SYMBOL) {
		translate([0, 0, top_base_height_back])
		rotate([-top_base_angle, 0, 0])
		translate([bottom_base_width/2, top_base_rotated_length/2 + top_base_translate, 0])
			symbol(top_base_rotated_length, symbol_number);
	}

	if (APPLY_SUPPORT) {
		translate([bottom_base_width, bottom_base_length/2, 0])
			support(bottom_base_angle_side);

		translate([0, bottom_base_length/2, 0])
		rotate([0, 0, 180])
			support(bottom_base_angle_side);

		translate([bottom_base_width/2, bottom_base_length, 0])
		rotate([0, 0, 90])
			support(bottom_base_angle_front);

		translate([bottom_base_width/2, 0, 0])
		rotate([0, 0, -90])
			support(bottom_base_angle_back);
	}
}

// Generates the support used for CNC machining the key
module support(bottom_base_angle_side) {
	support_base_translate = SUPPORT_HEIGHT/tan(bottom_base_angle_side);

	translate([-support_base_translate, SUPPORT_WIDTH/2, 0])
	rotate([90, 0, 0])
	linear_extrude(height=SUPPORT_WIDTH)
		polygon([[0, SUPPORT_HEIGHT], [support_base_translate, 0], [support_base_translate + SUPPORT_LENGTH, 0], [support_base_translate + SUPPORT_LENGTH, SUPPORT_HEIGHT]]);
}

// Generates the connector for the key
module connector(top_base_height_back) {
	sagitta_difference = sagitta(CONNECTOR_RADIUS, CONNECTOR_THICKNESS);

	union() {
		difference() {
			cylinder(h=top_base_height_back - CONNECTOR_HEIGHT, r = CONNECTOR_RADIUS);
			cylinder(h=top_base_height_back - CONNECTOR_HEIGHT, r = CONNECTOR_RADIUS - CONNECTOR_THICKNESS);

			translate([-CONNECTOR_MIDDLE_SPACE/2, -CONNECTOR_RADIUS, 0])
				cube([CONNECTOR_MIDDLE_SPACE, 2 * CONNECTOR_RADIUS, top_base_height_back - CONNECTOR_HEIGHT - CONNECTOR_SUPPORT_HEIGHT]);
		}
	}
}

module connector_test() {
	translate([0, 0, top_base_height_back - CONNECTOR_HEIGHT])
		base(top_base_width, top_base_rotated_length, KEY_THICKNESS);

	translate([top_base_width/2, top_base_length/2, 0])
		connector();
}

module symbol(top_base_rotated_length, symbol_number) {
	symbol_path = SYMBOL_FILES[symbol_number];
	symbol_initial_width = dxf_dim(file=symbol_path, name="total_width");
	symbol_initial_length = dxf_dim(file=symbol_path, name="total_height");

	symbol_width_scale = (top_base_width - SYMBOL_SPACING)/symbol_initial_width;
	symbol_length_scale = (top_base_rotated_length - SYMBOL_SPACING)/symbol_initial_length;
	symbol_scale = min(symbol_width_scale, symbol_length_scale);
	symbol_width = symbol_initial_width * symbol_scale;
	symbol_length = symbol_initial_length * symbol_scale;

	if (DEBUG_SYMBOL) {
		color("blue")
		translate([-symbol_width/2, -symbol_length/2, 0])
			cube([symbol_width, symbol_length, 0.1]);
	}

	color("red")
	translate([symbol_width/2, symbol_length/2, 0])
	scale([symbol_scale, symbol_scale, 1])
	rotate([0, 0, 180])
	linear_extrude(height=SYMBOL_THICKNESS)
		import(file=symbol_path);
}
