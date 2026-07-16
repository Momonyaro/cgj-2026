shader_type spatial;
render_mode cull_disabled;

uniform sampler2D front_texture : source_color;
uniform sampler2D back_texture : source_color;

void fragment() {
	if (FRONT_FACING) {
		vec4 front_col = texture(front_texture, UV);
		ALBEDO = front_col.rgb;
		ALPHA = 1.0; // <- FORCE this to 1.0 temporarily to see if pixels are updating!
	} else {
		vec2 back_uv = vec2(1.0 - UV.x, UV.y); 
		vec4 back_col = texture(back_texture, back_uv);
		ALBEDO = back_col.rgb;
		ALPHA = back_col.a;
	}
}
