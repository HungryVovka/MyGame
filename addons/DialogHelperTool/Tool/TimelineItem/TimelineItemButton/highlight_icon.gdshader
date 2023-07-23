shader_type canvas_item;

uniform bool is_active = true;
uniform vec4 active_color: source_color = vec4(0.8, 0.7, 0.3, 0.77);
uniform vec4 inactive_color: source_color = vec4(0.5, 0.6, 0.8, 0.7);

vec4 blend(vec4 src) {
    if (src.a < 0.4)
        return src;
    if (is_active)
        return active_color;
    else
        return inactive_color;
}

void fragment() {
    COLOR = blend(texture(TEXTURE, UV));
}