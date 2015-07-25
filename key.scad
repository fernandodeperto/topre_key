bottom_base_width = 18.10;
bottom_base_length = 18.10;

top_base_height_back = 9.39;
top_base_height_front = 9.39;
top_base_width = 12.37;
top_base_length = 14.65;

connector_dimensions = [4.1, 1.35];
connector_radius = 2.77;
connector_height = 4.58;

support_height = 1.5;
support_depth = 0.5;

base_angle = 69.78;
base_radius = 1.5;
thickness = 1.2;
cylinder_radius = 40;

$fn = 720;

cylinder_translate_distance = sagitta(cylinder_radius, top_base_width);
key_scale = (bottom_base_width - thickness) / bottom_base_width;
top_base_angle = atan((top_base_height_back - top_base_height_front)/top_base_length);

function sagitta(radius, chord) = radius - pow(pow(radius, 2) - pow(chord/2, 2), 0.5);


module base(width, length) {
	linear_extrude(height=0.001)
		minkowski() {
			square([width - 2 * base_radius, length - 2 * base_radius]);
			translate([base_radius, base_radius, 0]) circle(base_radius);
		}
}

module key_shape() {
	top_base_new_length = pow(pow(top_base_length, 2) + pow(top_base_height_back - top_base_height_front, 2), 0.5);
	cylinder_rotated_translate_z = cos(top_base_angle) * cylinder_translate_distance;
	cylinder_rotated_translate_y = sin(top_base_angle) * cylinder_translate_distance;
	
	cylinder_bizarre_size = cylinder_rotated_translate_z/tan(base_angle - top_base_angle);
	//cylinder_bizarre_size = 0.25;
	echo(cylinder_bizarre_size);

	//difference() {
		//hull() {
			base(bottom_base_width, bottom_base_width);

			translate([(bottom_base_width - top_base_width) / 2, 0, top_base_height_back])
			rotate([-top_base_angle, 0, 0])
				base(top_base_width, top_base_new_length);
		//}
	
		translate([bottom_base_width/2, -cylinder_rotated_translate_y, top_base_height_back - cylinder_rotated_translate_z])
		rotate([-top_base_angle, 0, 0])
		translate([0, top_base_new_length + cylinder_bizarre_size, cylinder_radius])
		rotate([90, 0, 0])
			*cylinder(h = top_base_new_length + cylinder_bizarre_size, r = cylinder_radius, center=false);
//		translate([0, 0, top_base_height_back])
//		rotate([-top_base_angle, 0, 0])
//		translate([bottom_base_width/2 - top_base_width/2, 0, 0])
//			cube([top_base_width, top_base_new_length, cylinder_radius], center=false);
			


	//}
}

module connector() {
	difference() {
		cylinder(h = connector_height, r = connector_radius);
        
		translate([-connector_dimensions[0]/2, -connector_dimensions[1]/2, 0])
			cube([connector_dimensions[0], connector_dimensions[1], connector_height], false);
        
		rotate([0, 0, 90])
			translate([-connector_dimensions[0]/2, -connector_dimensions[1]/2, 0])
				cube([connector_dimensions[0], connector_dimensions[1], connector_height], false);
	}
}

module support_shape(top_base_length) {
	base_difference = support_height/tan(base_angle);
	base_length = top_base_length + 2 * base_difference;
	
	rotate([90, 0, 0])
		linear_extrude(height = support_depth)
			polygon([[0, 0], [base_length, 0], [top_base_length + base_difference, support_height], [base_difference, support_height]]);
}

module support() {
	base_difference = support_height/tan(base_angle);

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
	difference() {
		key_shape();
		*translate([thickness/2, thickness/2, 0]) 
			scale(key_scale) 
				key_shape();
	}
	
	*translate([bottom_base_width/2, bottom_base_width/2, top_base_height_back - connector_height - cylinder_translate_distance])
		connector();
	
	*translate([bottom_base_width/2, bottom_base_width/2, top_base_height_back - support_height - cylinder_translate_distance])
		support();
}

key();

//insert_part = 1;
//move_part = insert_part/tan(base_angle);
//echo(move_part);
//
//difference() {
//translate([0, 1, 0])
//rotate([90, 0, 0]) 
//linear_extrude(height=2) 
//	polygon([[0,0], [bottom_base_width, 0], [bottom_base_width, top_base_height_back], [bottom_base_length-top_base_length, top_base_height_front]]);
//
//	translate([0, -1, 0])
//		%cube([top_base_length / cos(top_base_angle) + 5, 2, 15]);
//}
