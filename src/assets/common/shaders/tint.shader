shader_type canvas_item;

uniform vec4 tint_color: hint_color;
uniform float tint_amount: hint_range(0.0, 1.0);

void fragment()
{
	vec4 color = texture(TEXTURE, UV);
	if (color.a > 0.0)
	{
		COLOR *= mix(color, tint_color, tint_amount);
	}
	else
	{
		COLOR = color;
	}
}