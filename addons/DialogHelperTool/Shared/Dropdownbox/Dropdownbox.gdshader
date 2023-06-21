shader_type canvas_item;

uniform bool is_active = true;

vec4 blend(vec4 src) {
    if (src.a < 0.1)
        return src;
    if (is_active)
        return vec4(0.8, 0.7, 0.3, 0.77);
    else
        return vec4(0.4, 0.4, 0.4, 0.4);
}

void fragment() {

    COLOR = blend(texture(TEXTURE, UV));
}