varying vec2 v_coord;
varying float v_depth;

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_coord);
	if (base.a < 0.8)
	{
		discard;
	}
	
	gl_FragColor = vec4(v_depth);
}