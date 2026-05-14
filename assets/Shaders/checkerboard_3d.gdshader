shader_type spatial;

uniform float scale : hint_range(0.1, 50.0) = 5.0;
uniform vec3 color1 : source_color = vec3(1.0, 0.6, 0.2); // Orange
uniform vec3 color2 : source_color = vec3(0.4, 0.0, 0.0); // Dark Red

void vertex() {
	// Store the vertex position for use in fragment shader
}

void fragment() {
	// Get 3D world position
	vec3 pos = MODEL_MATRIX * scale;
	
	// Use floor to create grid cells
	vec3 grid = floor(pos);
	
	// Sum the grid coordinates and check if even or odd
	float checker = mod(grid.x + grid.y + grid.z, 2.0);
	
	// Mix between the two colors based on checker pattern
	vec3 final_color = mix(color1, color2, checker);
	
	ALBEDO = final_color;
}
