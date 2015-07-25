$fn = 360;

base_radius = 1.5;

bottom_base_length = 18.10;
bottom_base_width = 18.10;
bottom_base_angle = 69.78;

top_base_height_back = 9.39;
top_base_height_front = 8.39;
top_base_width = 12.37;

default_base_extrusion_height = .001;

key_thickness = 1;

cylinder_dish_radius = 40;

// Calculated stuff
top_base_length = bottom_base_length - top_base_height_front/tan(bottom_base_angle);
top_base_angle = atan((top_base_height_back-top_base_height_front)/top_base_length);
top_base_rotated_length = top_base_length/cos(top_base_angle);
key_scale = (bottom_base_width - 2 * key_thickness) / bottom_base_width;

dish_translate_distance = sagitta(cylinder_dish_radius, top_base_width);

function sagitta(radius, chord) = radius - pow(pow(radius, 2) - pow(chord/2, 2), 0.5);

module base(width, length) {
		minkowski() {
			cube([width - 2 * base_radius, length - 2 * base_radius, default_base_extrusion_height]);
			translate([base_radius, base_radius, 0]) 
				cylinder(h=default_base_extrusion_height, r=base_radius);
		}
}

module key_shape() {
	rotated_cylinder_translate = dish_translate_distance/tan(bottom_base_angle-top_base_angle);
	
	difference() {
		hull() {
			base(bottom_base_length, bottom_base_length);
			
			translate([(bottom_base_width-top_base_width)/2, 0, top_base_height_back - default_base_extrusion_height])
			rotate([-top_base_angle, 0, 0])
				base(top_base_width, top_base_rotated_length);
		}

		translate([bottom_base_width/2, 0, top_base_height_back])
		rotate([-top_base_angle, 0, 0])
		translate([0, top_base_rotated_length + rotated_cylinder_translate, cylinder_dish_radius - dish_translate_distance])
		rotate([90,0,0])
			cylinder(h=top_base_rotated_length + rotated_cylinder_translate, r=cylinder_dish_radius);
	}
}

module key() {
	difference() {
		key_shape();
		
		//translate([key_thickness, key_thickness, 0])
		//scale(key_scale)
			//key_shape();
	}
}

key();




