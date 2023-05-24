shader_type canvas_item;

uniform float time = 0.0;
uniform sampler2D secondTexture;

uniform bool swipe_mode_horizontal = false;
uniform bool swipe_mode_vertical = false;
uniform float swipe_speed_horizontal = 1.0;
uniform float swipe_speed_vertical = 1.0;
uniform float swipe_limit_x_min = -1920.0;
uniform float swipe_limit_x_max = 1920.0;
uniform float swipe_limit_y_min = -1080.0;
uniform float swipe_limit_y_max = 1080.0;
uniform float shift_x = 0.0;
uniform float shift_y = 0.0;


uniform bool scale_mode = false;
uniform float scale_speed = 1.0;
uniform float scale_min = 0.0;
uniform float scale_max = 1.0;
uniform float scale_shift = 0.0;

uniform bool shake_mode = false;
uniform bool shake_vertical = true;
uniform bool shake_horizontal = true;
uniform float shake_speed = 1.0;
uniform float shake_height = 0.0;
uniform float shake_time = 1.0;

uniform bool blend_mode = true;
uniform float blend_speed = 1.0;

uniform vec4 src_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform bool fade_to = false;
uniform bool fade_from = false;
uniform float fade_speed = 1.0; 

uniform bool slide_mode_x = true;
uniform bool slide_mode_y = true;
uniform float slide_speed = 0.05;
uniform bool slide_reverse = false;

void vertex() {
	if (swipe_mode_horizontal) {
		VERTEX.x += shift_x + max(min(time * swipe_speed_horizontal, swipe_limit_x_max), swipe_limit_x_min);
	}
	if (swipe_mode_vertical) {
		VERTEX.y += shift_y + max(min(time * swipe_speed_vertical, swipe_limit_y_max), swipe_limit_y_min);
	}
	if (scale_mode) {
		float scale = max(min(time * scale_speed + scale_shift, scale_max), scale_min);
		vec2 scaled = VERTEX * scale;
		VERTEX = scaled + vec2((1920.0 - 1920.0*scale)/2.0, (1080.0 - 1080.0*scale)/2.0);
	}
	if (shake_mode) {
		if (time < shake_time) {
			if (shake_vertical) {
				VERTEX.y += shake_height * sin(shake_speed * time);
			}
			if (shake_horizontal) {
				VERTEX.x += shake_height * cos(shake_speed * time);
			}
		}
	}
}

vec4 blend(vec4 color, vec4 blend){
	float blend_pos = min(max(time * blend_speed, 0.0), 1.0);
	return color * (1.0 - blend_pos) + blend * blend_pos;
}
vec4 blend_to(vec4 color){
	float blend_pos = min(max(time * fade_speed, 0.0), 1.0);
	return color * (1.0 - blend_pos) + src_color * blend_pos;
}

vec4 blend_from(vec4 color){
	float blend_pos = min(max(time * fade_speed, 0.0), 1.0);
	return src_color * (1.0 - blend_pos) + color * blend_pos;
}

vec4 slideX(sampler2D tex, vec4 color, vec2 pos) {
	float slide_pos = min(max(slide_speed * time, 0.0), 1.0);
	if (slide_reverse)
		slide_pos = 1.0 - slide_pos;
	if (pos.x >= slide_pos) 
		if (slide_reverse)
			return texture(secondTexture, pos - vec2(slide_pos, 0.0));
		else 
			return texture(tex, pos - vec2(slide_pos, 0.0));
	else
		if (slide_reverse)
			return texture(tex, vec2(1.0 - slide_pos, 0.0) + pos);
		else
			return texture(secondTexture, vec2(1.0 - slide_pos, 0.0) + pos);
}

vec4 slideY(sampler2D tex, vec4 color, vec2 pos) {
	float slide_pos = min(max(slide_speed * time, 0.0), 1.0);
	if (slide_reverse)
		slide_pos = 1.0 - slide_pos;
	if (pos.y >= slide_pos) 
		if (slide_reverse)
			return texture(secondTexture, pos - vec2(0.0, slide_pos));
		else 
			return texture(tex, pos - vec2(0.0, slide_pos));
	else
		if (slide_reverse)
			return texture(tex, vec2(0.0, 1.0 - slide_pos) + pos);
		else
			return texture(secondTexture, vec2(0.0, 1.0 - slide_pos) + pos);
}

void fragment() {
	if (blend_mode)
		COLOR = blend(COLOR, texture(secondTexture, UV));
	if (fade_to)
		COLOR = blend_to(COLOR);
	if (fade_from)
		COLOR = blend_from(COLOR);
	if (slide_mode_x)
		COLOR = slideX(TEXTURE, COLOR, UV);
	if (slide_mode_y)
		COLOR = slideY(TEXTURE, COLOR, UV);
}