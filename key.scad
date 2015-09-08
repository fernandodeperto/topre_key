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
	[10.4, 64, 3], // Row E (default: [10.4, 3])
	[8.2, 60, -2], // Row D (default: [8.2, -2])
	[7, 58, -6], // Row C (default: [7, -6])
	[6.7, 60, -13], // Row B (default: [6.7, -13])
	[6.7, 60, -13], // Row A (default: [6.7, -13])
];

// Dimensions that are relevant to all rows
key_dimensions = [
	0.6, // Top base sagitta (default: 0.6)
	11.5, // Top base width (default: 11.5)
	18, // Bottom base length (default: 18)
	18, // Bottom base width (default: 18)
	86, // Bottom base back angle (default: 86)
];

// Symbol
symbol_files = [
	"dxf/deathly_hallows.dxf", // 0
	"dxf/harry_potter.dxf", // 1
	"dxf/mockinjay.dxf", // 2
	"dxf/playstation.dxf", // 3
	"dxf/jedi_order.dxf", // 4
	"dxf/rebel_alliance.dxf", // 5
	"dxf/republic.dxf", // 6
	"dxf/sith_order.dxf", // 7
	"dxf/stark.dxf", // 8
	"dxf/D3.dxf", // 9
	"dxf/protoss.dxf", // 10
	"dxf/terran.dxf", // 11
	"dxf/zerg.dxf", // 12
	"dxf/kojima.dxf", // 13
];

symbol_path = symbol_files[7];
symbol_thickness = 0.4;
symbol_spacing = 1.4;

// Some rendering options
apply_keyboard_angle = 0;
apply_key_angle = 1;
apply_cylindrical_dish = 0;
apply_symbol = 0;

// Key dimensions
top_base_sagitta = apply_cylindrical_dish ? key_dimensions[0] : 0;
top_base_width = key_dimensions[1] * key_size;
bottom_base_length = key_dimensions[2];
bottom_base_width = key_dimensions[3] - key_dimensions[1] + key_dimensions[1] * key_size;
bottom_base_angle_back = key_dimensions[4];

//connector_test();

rotate([apply_keyboard_angle ? -keyboard_angle : 0, 0, 0])
	key(0);
