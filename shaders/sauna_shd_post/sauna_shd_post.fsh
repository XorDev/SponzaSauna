varying vec4 v_color;
varying vec2 v_coord;

uniform sampler2D u_shade;

//Number of texture samples. Higher = smoother, slower
#define SAMPLES 24.0
//Blur radius (in pixels)
#define RADIUS 3.0

void main()
{
	//Base color
	vec4 base = texture2D(gm_BaseTexture, v_coord);
	
	//Initialize blur output color
	vec4 blur = vec4(0);
	//Total weight from all samples
	float total = 0.;
	
	//First sample offset scale
	float scale = RADIUS / sqrt(SAMPLES);
	//Try without noise here:
	vec2 point = vec2(scale,0);
	
	vec2 texel = vec2(dFdx(v_coord.x), dFdy(v_coord.y));
	//Radius iteration variable
	float rad = 1.0;
	//Golden angle rotation matrix
	mat2 ang = mat2(-0.7373688, -0.6754904, 0.6754904,  -0.7373688);
	
	//Look through all the samples
	for(float i = 0.0; i<SAMPLES; i++)
	{
		//Rotate point direction
		point *= ang;
		//Iterate radius variable. Approximately 1+sqrt(i)
		rad += 1.0/rad;
		
		//Get sample coordinates
		vec2 coord = v_coord + point*(rad-1.0) * texel;
		//Set sample weight
		float weight = 1.0/rad;
		//Sample texture
		vec4 samp = texture2D(u_shade, coord);
		
		//Add sample and weight totals
		blur += samp * weight;
		total += weight;
	}
	//Divide the blur total by the weight total
	blur /= total;
	
	blur.r = texture2D(u_shade, v_coord).r;
	vec3 hue = cos(vec3(3,5,7)*(1.0-blur*blur).b)*0.1+0.8;
	
	base.rgb *= 1.0 - vec3(0.9,0.8,0.7) * (1.0 - min(blur.r, blur.g));
	base.rgb = mix(base.rgb, hue * blur.b, blur.a);
	base.a = 1.0;
	
	//Output result
	gl_FragColor = v_color * base;
}
