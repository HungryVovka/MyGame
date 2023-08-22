shader_type canvas_item;

uniform float whiteness_level = 0.0;

vec3 blw(vec3 c) {
	return (vec3(1.0, 1.0, 1.0) - c)*whiteness_level + c;
}

void fragment() {
	COLOR = vec4(blw(COLOR.rgb), COLOR.a * (max(1.0 - whiteness_level, 0.5)));
}
