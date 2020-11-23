shader_type canvas_item;

uniform vec4 tint: hint_color = vec4(0.0);
uniform float progress: hint_range(0, 1);

void fragment()
{
	vec4 current_color = texture(TEXTURE, UV);
	COLOR = current_color;
	if (current_color.a > 0.0 && UV.y >= progress)
	{
		
		COLOR = mix(COLOR, tint, 0.5);
	}
}