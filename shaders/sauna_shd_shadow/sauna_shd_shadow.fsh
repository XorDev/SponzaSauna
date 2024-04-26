uniform sampler2D u_texMetallicRoughness;
uniform sampler2D u_texNormal;

varying vec2 v_coord;
varying vec3 v_normal;
varying vec4 v_world;

uniform vec2 u_fog;//Density, height
uniform vec3 u_cam;
uniform sampler2D u_noise;
uniform sampler2D u_shadow;
uniform mat4 u_shadow_view;
uniform mat4 u_shadow_proj;

float smax(float a, float b)
{
    return a*a>b*b? a : b;
}

vec2 shadow_uv(vec4 proj, vec2 o)
{
	vec2 shadow_coord = proj.xy / proj.w + o;
	return shadow_coord * vec2(0.5,-0.5) + 0.5;	
}

float shadow_sample(vec4 view, vec2 o, float i)
{
	vec4 shadow_proj = u_shadow_proj * view;
	vec2 shadow_coord = shadow_uv(shadow_proj, o);
	
	vec2 shadow_sign = shadow_coord * 2.0 - 1.0;
	vec2 edge = max(1.0 - shadow_sign * shadow_sign, 0.0);
	edge *= edge;
	float vignette = edge.x*edge.y * clamp(view.z, 0.0, 1.0);
	
	//In shadow
	if (shadow_proj.z<-i) return 0.0; // || clamp(shadow_coord, 0.0, 1.0) != shadow_coord
		
	float shade = (texture2D(u_shadow, shadow_coord).r - view.z)*1e2+1.0+length(o)*1e3;
	return clamp(shade, 0.0, 1.0) * vignette;
}

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_coord);
	if (base.a < 0.8)
	{
		discard;
	}
	#define NUM 32.0
	vec4 noi = texture2D(u_noise, gl_FragCoord.xy/128.);
	vec4 shadow_view = u_shadow_view * v_world;
	
	float len = length(u_cam - v_world.xyz);
	vec2 o = (noi.xy-0.5)*shadow_view.z/4e3;
	float shade = shadow_sample(shadow_view, o, 1.0);
	vec2 fog = vec2(0);
	float I = noi.z/NUM;
	
	for(float i=0.0; i<NUM; i++)
	{
		I += 1.0/NUM;
		
		shadow_view = u_shadow_view * mix(vec4(u_cam,1), v_world, I);
		
		fog += vec2(shadow_sample(shadow_view,o,I) - fog.r*.4,
		
		min(len*u_fog.x/6e1*smoothstep(0.0,1.0,1.0+(u_fog.y-v_world.z*I)/3.0), 1.0))*(1.0-fog.g)/sqrt(NUM);
	}
	
	vec2 metallicRoughness = texture2D(u_texMetallicRoughness, v_coord).bg;
	vec3 normal = normalize( texture2D(u_texNormal, v_coord).rgb * 2.0 - 1.0);
	
	// compute derivations of the world position
	vec3 p_dx = dFdx(v_world.xyz);
	vec3 p_dy = dFdy(v_world.xyz);
	// compute derivations of the texture coordinate
	vec2 tc_dx = dFdx(v_coord);
	vec2 tc_dy = dFdy(v_coord);
	// compute initial tangent and bi-tangent
	vec3 t = normalize(tc_dy.y * p_dx - tc_dx.y * p_dy);
	vec3 b = normalize(tc_dx.x * p_dy - tc_dy.x * p_dx);
	// get new tangent from a given mesh normal
	vec3 n = normalize(-mat3(u_shadow_view) * v_normal);
	vec3 x = cross(n, t);
	t = cross(x, n);
	t = normalize(t);
	// get updated bi-tangent
	x = cross(b, n);
	b = cross(n, x);
	b = normalize(b);
	mat3 tbn = mat3(t, b, n);
	normal = normalize(tbn * normal);
	
	float rim = max(normal.z, 0.0);
	vec3 col = base.rgb;//vec3(.1,.03,.01)/length(shadow_uv(v_world,vec2(0))-
						//			   shadow_uv(vec4(u_cam,(u_shadow_view*vec4(u_cam,1)).w),vec2(0)));//base.rgb;
	//col = vec3(shadow_uv(v_world*vec4(noi.xxx,1), vec2(0)),0);
	gl_FragData[0] = vec4(col, 1.0);
	gl_FragData[1] = vec4(rim, shade, fog);
}