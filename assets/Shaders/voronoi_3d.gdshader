shader_type spatial;

uniform float scale : hint_range(1.0, 50.0) = 10.0;
uniform float smoothness : hint_range(0.0, 1.0) = 0.1;

// Hash function for random numbers
vec3 hash3(vec3 p) {
	p = fract(p * 0.13456);
	p += dot(p, p.yzx + 33.33);
	return fract((p.xxy + p.yxx) * p.zyx);
}

// 3D Voronoi
float voronoi_3d(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	
	float min_dist = 2.0;
	
	// Check neighboring cells
	for(int z = -1; z <= 1; z++) {
		for(int y = -1; y <= 1; y++) {
			for(int x = -1; x <= 1; x++) {
				vec3 neighbor = vec3(float(x), float(y), float(z));
				vec3 point = hash3(i + neighbor);
				vec3 diff = neighbor + point - f;
				float dist = length(diff);
				min_dist = min(min_dist, dist);
			}
		}
	}
	
	return min_dist;
}

void fragment() {
	// Get 3D object position (stays static relative to object)
	vec3 scaled_pos = VERTEX * scale;
	
	// Calculate Voronoi pattern
	float voronoi = voronoi_3d(scaled_pos);
	
	// Smoothstep for smoothness control
	float pattern = smoothstep(0.0, smoothness, voronoi);
	
	// Create 3-level color ramp: orange -> red -> dark red
	vec3 color;
	if(pattern < 1.0) {
		// Orange to Red
		float t = pattern * 2.0; // 0 to 1 within this range
		vec3 orange = vec3(1.0, 0.6, 0.2);
		vec3 red = vec3(1.0, 0.0, 0.0);
		color = mix(orange, red, t);
	} else {
		// Red to Dark Red
		float t = (pattern - 0.5) * 2.0; // 0 to 1 within this range
		vec3 red = vec3(1.0, 0.0, 0.0);
		vec3 dark_red = vec3(0.4, 0.0, 0.0);
		color = mix(red, dark_red, t);
	}
	
	ALBEDO = color;
}
