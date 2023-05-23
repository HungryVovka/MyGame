shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float speed = 1.00;
uniform float time = 0.0;
uniform float coef_x = 1.0;
uniform float coef_y = 1.0;
uniform float power = 2.0;
uniform float fade_out_speed = 0.5;

float cut_edge(float v, float coef) {	
	float val = -speed*pow(time, power)*coef*(pow(v - 0.5,2.0)) + 1.0;
	return max(val, 0.0) * cos(min(time/speed*fade_out_speed, 1.0) * 3.14/2.0);
}

float edges(float x, float y) {
	return cut_edge(x, coef_x) * cut_edge(y, coef_y);
}

void fragment() {
	COLOR = vec4((texture(SCREEN_TEXTURE, SCREEN_UV)*edges(SCREEN_UV.x, SCREEN_UV.y)).rgb, 1.0);
}
