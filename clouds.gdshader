shader_type canvas_item;

uniform sampler2D cloud_texture : repeat_enable;
uniform vec2 scroll_speed = vec2(0.02, 0.01); // How fast clouds move
uniform float opacity : hint_range(0.0, 1.0) = 0.3; // Cloud transparency

void fragment() {
	// Calculate UV offset based on time
	vec2 uv = UV + TIME * scroll_speed;
	
	// Sample the cloud texture with the offset
	vec4 cloud = texture(cloud_texture, uv);
	
	// Apply opacity
	COLOR = vec4(cloud.rgb, cloud.a * opacity);
}
