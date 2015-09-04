include<modules.scad>;

// Render precision
// Set this to a small value for fast renders
$fn = 100;

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

// Dimension fields:
// 0: top_base_height_back
// 1: top_base_height_front
// 2: top_base_rotated_length
// 3: top_base_width

// Topre dimensions
row_dimensions = [
	[10.4, 10], // Row E (default: [10.4, 1])
	[8.2, -2], // Row D (default: [8.2, -2])
	[7, -6], // Row C (default: [7, -6])
	[6.7, -13], // Row B (default: [6.7, -13])
	[6.7, -13], // Row A (default: [6.7, -13])
];

// Dimensions that are relevant to all rows
key_dimensions = [
	0.6, // Top base sagitta (default: 0.6)
	11.5, // Top base width
	18, // Bottom base length
	18, // Bottom base width
	66, // Bottom base angle
];

// Symbol
symbol_path = "dxf/D3.dxf";
symbol_thickness = 0.5;
symbol_spacing = 1.4;

// Some rendering options
apply_keyboard_angle = 0;
apply_key_angle = 1;
apply_cylindrical_dish = 0;
apply_symbol = 1;

// Key dimensions
top_base_sagitta = apply_cylindrical_dish ? key_dimensions[0] : 0;
top_base_width = key_dimensions[1] * key_size;
bottom_base_length = key_dimensions[2];
bottom_base_width = key_dimensions[3] - key_dimensions[1] + key_dimensions[1] * key_size;
bottom_base_angle = key_dimensions[4];

// Functions used to calculate dimensions of the cylindrical dish
function sagitta(radius, chord) = radius - pow(pow(radius, 2) - pow(chord/2, 2), 0.5);
function central_chord(chord, sagitta) = pow(chord/2, 2)/sagitta;
function cylinder_radius(chord, sagitta) = (central_chord(chord, sagitta) + sagitta)/2;

//connector_test();

rotate([apply_keyboard_angle ? -keyboard_angle : 0, 0, 0])
	key(1);
