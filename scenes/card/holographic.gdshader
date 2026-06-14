shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float overlay_alpha = 0.32;
uniform float sweep_speed = 0.213;
uniform float sweep_width = 0.075;
uniform float shimmer_strength = 0.2;

void fragment() {
	vec2 uv = UV;
	float diagonal = (uv.x * 0.78) + ((1.0 - uv.y) * 0.62);
	float sweep = abs(fract(diagonal - (TIME * sweep_speed)) - 0.5);
	float sweep_mask = smoothstep(sweep_width, 0.0, sweep);
	float second_sweep = abs(fract((diagonal * 1.7) + (TIME * 0.12)) - 0.5);
	float glint = smoothstep(0.045, 0.0, second_sweep);
	float blink = sin(TIME * 5.333 + uv.x * 18.0 + uv.y * 9.0) * 0.5 + 0.5;
	float grain = sin((uv.x * 92.0) + (uv.y * 57.0) + (TIME * 3.333)) * 0.5 + 0.5;
	vec3 foil_color = mix(vec3(0.88, 0.96, 1.0), vec3(1.0, 0.98, 0.88), grain * 0.18);
	float brightness = 0.34 + (sweep_mask * 0.72) + (glint * 0.42) + (blink * shimmer_strength);

	COLOR = vec4(foil_color * brightness, overlay_alpha * (0.28 + (sweep_mask * 0.52) + (glint * 0.2)));
}
