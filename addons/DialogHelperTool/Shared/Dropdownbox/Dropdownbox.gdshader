shader_type canvas_item;
vec4 blend(vec4 src) {
	if (src.a < 0.1)
		return src;
	return vec4(0.8, 0.7, 0.3, 0.77);
	}

void fragment() {
	
	COLOR = blend(texture(TEXTURE, UV));
}
