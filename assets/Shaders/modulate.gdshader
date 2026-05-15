shader_type spatial;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int blend_mode : hint_range(0, 5) = 0;
// 0: Multiply (default)
// 1: Screen
// 2: Overlay
// 3: Soft Light
// 4: Hard Light
// 5: Color Dodge

vec3 blend_multiply(vec3 base, vec3 blend) {
	return base * blend;
}

vec3 blend_screen(vec3 base, vec3 blend) {
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

vec3 blend_overlay(vec3 base, vec3 blend) {
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), step(0.5, base));
}

vec3 blend_soft_light(vec3 base, vec3 blend) {
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), 2.0 * base * (1.0 - blend) + sqrt(base) * (2.0 * blend - 1.0), step(0.5, blend));
}

vec3 blend_hard_light(vec3 base, vec3 blend) {
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), step(0.5, blend));
}

vec3 blend_color_dodge(vec3 base, vec3 blend) {
	return mix(base / (1.0 - blend + 0.001), base, step(0.99, blend));
}

void fragment() {
	vec3 result;
	
	if (blend_mode == 0) {
		result = blend_multiply(ALBEDO, tint_color.rgb);
	} else if (blend_mode == 1) {
		result = blend_screen(ALBEDO, tint_color.rgb);
	} else if (blend_mode == 2) {
		result = blend_overlay(ALBEDO, tint_color.rgb);
	} else if (blend_mode == 3) {
		result = blend_soft_light(ALBEDO, tint_color.rgb);
	} else if (blend_mode == 4) {
		result = blend_hard_light(ALBEDO, tint_color.rgb);
	} else {
		result = blend_color_dodge(ALBEDO, tint_color.rgb);
	}
	
	ALBEDO = result;
	ALPHA = ALPHA * tint_color.a;
}
