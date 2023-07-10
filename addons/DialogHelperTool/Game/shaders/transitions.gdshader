shader_type canvas_item;

uniform float time = 0.0;
uniform sampler2D secondTexture;

uniform bool swipe_mode_h = false;
uniform bool swipe_mode_v = false;
uniform float swipe_speed_h = 1.0;
uniform float swipe_speed_v = 1.0;
uniform float swipe_min_h = -1920.0;
uniform float swipe_max_h = 1920.0;
uniform float swipe_min_v = -1080.0;
uniform float swipe_max_v = 1080.0;
uniform float swipe_shift_h = 0.0;
uniform float swipe_shift_v = 0.0;


uniform bool scale_mode = false;
uniform float scale_speed = 1.0;
uniform float scale_min = 0.0;
uniform float scale_max = 1.0;
uniform float scale_shift = 0.0;

uniform bool shake_mode = false;
uniform bool shake_v = true;
uniform bool shake_h = true;
uniform float shake_speed = 1.0;
uniform float shake_height = 0.0;
uniform float shake_time = 1.0;

uniform bool blend_mode = false;
uniform float blend_speed = 1.0;

uniform vec4 fade_color: source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform bool fade_to = false;
uniform bool fade_from = false;
uniform float fade_speed = 1.0; 

uniform bool slide_h = false;
uniform bool slide_v = false;
uniform float slide_speed = 0.05;
uniform bool slide_reverse = false;

uniform float curtain_speed_h = 0.0;
uniform float curtain_speed_v = 0.0;
uniform bool curtain_h = false;
uniform bool curtain_v = false;
uniform bool curtain_reverse_h = false;
uniform bool curtain_reverse_v = false;

void vertex() {
	if (scale_mode) {
		float scale = max(min(time * scale_speed + scale_shift, scale_max), scale_min);
		vec2 scaled = VERTEX * scale;
		VERTEX = scaled + vec2((1920.0 - 1920.0*scale)/2.0, (1080.0 - 1080.0*scale)/2.0);
	}
	if (shake_mode) {
		if (time < shake_time) {
			if (shake_v) {
				VERTEX.y += shake_height * sin(shake_speed * time);
			}
			if (shake_h) {
				VERTEX.x += shake_height * cos(shake_speed * time);
			}
		}
	}
	if (swipe_mode_h) {
		VERTEX.x += swipe_shift_h + max(min(time * swipe_speed_h, swipe_max_h), swipe_min_h);
	}
	if (swipe_mode_v) {
		VERTEX.y += swipe_shift_v + max(min(time * swipe_speed_v, swipe_max_v), swipe_min_v);
	}
}

vec4 blend(vec4 color, vec4 blend){
	float blend_pos = min(max(time * blend_speed, 0.0), 1.0);
	return color * (1.0 - blend_pos) + blend * blend_pos;
}
vec4 blend_to(vec4 color){
	float blend_pos = min(max(time * fade_speed, 0.0), 1.0);
	return color * (1.0 - blend_pos) + fade_color * blend_pos;
}

vec4 blend_from(vec4 color){
	float blend_pos = min(max(time * fade_speed, 0.0), 1.0);
	return fade_color * (1.0 - blend_pos) + color * blend_pos;
}

vec4 slideX(sampler2D tex, vec2 pos) {
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

vec4 slideY(sampler2D tex, vec2 pos) {
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

bool curtainCheckX(vec2 pos) {
	float curtain_pos = min(max(curtain_speed_h * time, 0.0), 1.0);
	if (curtain_reverse_h)
		curtain_pos = 1.0 - curtain_pos;
	if (pos.x <= curtain_pos)
		if (curtain_reverse_h)
			return false;
		else
			return true;
	else
		if (curtain_reverse_h)
			return true;
		else
			return false;
}

bool curtainCheckY(vec2 pos) {
	float curtain_pos = min(max(curtain_speed_v * time, 0.0), 1.0);
	if (curtain_reverse_v)
		curtain_pos = 1.0 - curtain_pos;
	if (pos.y <= curtain_pos)
		if (curtain_reverse_v)
			return false;
		else
			return true;
	else
		if (curtain_reverse_v)
			return true;
		else
			return false;
}

vec4 curtain(bool checkX, bool checkY, sampler2D tex, vec2 pos) {
	bool x = false;
	bool y = false;
	if (checkX)
		x = curtainCheckX(pos);
	if (checkY)
		y = curtainCheckY(pos);
	bool checkResult = x || y;
	if (checkResult)
		return texture(secondTexture, pos);
	else
		return texture(tex, pos);	
}


void fragment() {
	vec2 uv = UV;

	if (slide_h)
		COLOR = slideX(TEXTURE, uv);
	if (slide_v)
		COLOR = slideY(TEXTURE, uv);
	COLOR = curtain(curtain_h, curtain_v, TEXTURE, uv);
	if (blend_mode) {
		ivec2 ibackSize = textureSize(TEXTURE, 0);
		ivec2 iBlendSize = textureSize(secondTexture, 0);
		vec2 diff = vec2(float(ibackSize.x) / float(iBlendSize.x), float(ibackSize.y) / float(iBlendSize.y));
		COLOR = blend(COLOR, texture(secondTexture, vec2(uv.x * diff.x, uv.y * diff.y)));
	}
	if (fade_to)
		COLOR = blend_to(COLOR);
	if (fade_from)
		COLOR = blend_from(COLOR);
}