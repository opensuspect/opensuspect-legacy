shader_type canvas_item;

uniform vec4 skin_mask_color: hint_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 skin_color: hint_color = vec4(1.0);
uniform float tolerance: hint_range(0.0, 1.0) = 0.5;

void fragment()
{
	vec4 color = texture(TEXTURE, UV);
	
	// Replace magenta skin mask color with proper skin color
	vec3 diff = color.rgb - skin_mask_color.rgb;
	float m = max(max(abs(diff.r), abs(diff.g)), abs(diff.b));
   	color.rgb = mix(color.rgb, skin_color.rgb, step(m, tolerance));
	COLOR = color;

}