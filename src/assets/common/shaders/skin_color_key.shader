shader_type canvas_item;

uniform vec4 skin_mask_color: hint_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 skin_color: hint_color = vec4(1.0);
uniform float tolerance: hint_range(0.0, 1.0) = 0.5;

void fragment()
{
	vec4 color_a = texture(TEXTURE, UV);
	vec3 color = color_a.rgb;
	float a = color_a.a;
	float mask_len = length(skin_mask_color.rgb);
	float c_len = length(color);
	// Change the lenght of the 3D color vector of the mask to the same length as the current color is for comparison
	vec3 mask_norm = skin_mask_color.rgb / mask_len * c_len;
	vec3 skin_color_norm = skin_color.rgb / mask_len * c_len;
	// Calculate the distance between the equal length vectors (ie, if they point to the same direction, the distance is 0)
	float dist = distance(color, mask_norm) * c_len * 10.0;
	// Replace magenta skin mask color with proper skin color
	color = mix(skin_color_norm, color, step(tolerance, dist));
	//color.rgb = mix(color.rgb, skin_color_norm.rgb, step(dist, tolerance));
	COLOR = vec4(color, a);

}