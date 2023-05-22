shader_type canvas_item;

uniform float speed = 0.08;

float waves(float v, float x, float y){
	return sin((TIME*speed + sin(x) - cos(y))/0.08)*(1.0 - v);
}
float wavesc(float v, float x, float y){
	return cos((TIME*speed - sin(x) - cos(y))/0.04)*(1.0 - v);
}

float yc(vec4 c) {
	return c.r * 0.299 + c.g * 0.587 + c.b * 0.114;
}

float cut_edges(float x, float y) {
	return (-pow((2.0*x-1.0), 2.0) + 1.0) * (-pow((2.0*y-1.0), 2.0) + 1.0);
	return 0.0;
}

vec4 avg(vec4 c, float x, float y) {
	float av = yc(c);
	float v = av - wavesc(av, x, y) + waves(av, x, y);
	v *= cut_edges(x, y);
	return vec4(v,v,v, c.a);
}

float colordiff(vec4 c, float v) {
	return (abs(c.r - v) + abs(c.g - v) + abs(c.b - v)) * 1.0;
}


vec4 blend(vec4 c, float x, float y) {
	vec4 v = avg(c, x, y);
	vec4 diff = v * colordiff(c, v.r);
	float sat = 1.12;
	return vec4(vec3(diff.r + (c.r - diff.r)/sat, 
	diff.g + (c.g - diff.g)/sat,
	diff.b + (c.b - diff.b)/sat) * cut_edges(x, y), 1.0);
}
void fragment() {
	float x = UV.x + sin(TIME*0.25)/1.1;
	float y = UV.y - cos(TIME*100.5)/64.0;
	COLOR = blend(texture(TEXTURE, UV - vec2(sin(TIME*0.5*pow(x*x*-y*y, -1.0))/64.0, cos(TIME*0.5*pow(y*y-x*x*x,-2))/120.0)), x, y);
}
