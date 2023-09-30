uniform sampler2D u_texMetallicRoughness;
uniform sampler2D u_texNormal;

varying vec2 v_coord;
varying vec3 v_normal;
varying vec4 v_world;
varying vec4 v_view;

uniform vec2 u_fog;//Density, height
uniform vec3 u_cam;
uniform sampler2D u_noise;
uniform sampler2D u_shadow;
uniform mat4 u_shadow_view;
uniform mat4 u_shadow_proj;

vec2 shadow_uv(vec4 p, vec2 o)
{
	vec4 shadow_view = p;
	shadow_view = u_shadow_view * shadow_view;
	vec4 shadow = u_shadow_proj * shadow_view;
	vec2 shadow_coord = shadow.xy / shadow.w + o;
	vec2 shadow_abs = abs(shadow_coord);
	shadow_coord /= max(max(shadow_abs.x, shadow_abs.y), 1.0);
	return shadow_coord * vec2(0.5,-0.5) + 0.5;	
}

float shadow_sample(vec4 p, vec2 o, float i)
{
	vec4 shadow_view = p;
	shadow_view = u_shadow_view * shadow_view;
	vec4 shadow = u_shadow_proj * shadow_view;
	vec2 //shadow_coord = shadow.xy / shadow.w;
	shadow_coord0 = shadow_uv(vec4(0,0,0,1), o),
	shadow_coord1 = shadow_uv(p, o),
	shadow_coord = mix(shadow_coord0, shadow_coord1, i);
	vec2 shadow_sign = shadow_coord * 2.0 - 1.0;
	vec2 edge = 1.0 - shadow_sign * shadow_sign;
	edge *= edge;
	//shadow_coord = shadow_coord * vec2(0.5,-0.5) + 0.5;
	//shadow_coord += o;
	
	if (shadow.z<-i) return 0.0;//clamp(shadow_coord, 0.0, 1.0) != shadow_coord || 
		
	float shade = (texture2D(u_shadow, shadow_coord).r - shadow_view.z)*1e2+1.0+length(o)*1e3;
	return clamp(shade, 0.0, 1.0) * edge.x * edge.y;
}

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_coord);
	if (base.a < 0.8)
	{
		discard;
	}
	#define NUM 10.0
	vec4 noi = texture2D(u_noise,gl_FragCoord.xy/128.);
	vec4 shadow_view = u_shadow_view * v_view;
	float len = length(u_cam - v_view.xyz);
	vec2 o = (noi.xy-0.5)*shadow_view.z/4e3;
	float shade = shadow_sample(v_view,o,1.0);
	vec2 fog = vec2(0);
	for(float i=0.0; i<NUM; i++)
	{
		float I = (i+noi.z)/NUM;
		//vec4 shadow_view = v_view;
		//shadow_view.xyz = mix(u_cam, v_view.xyz, (i+noi.z)/NUM);
		fog += vec2(shadow_sample(v_view,vec2(0),I)-fog.r*.4,
		min(len*len*u_fog.x/6e2*smoothstep(0.0,1.0,1.0+(u_fog.y-v_view.z*I)/3.0), 1.0))*(1.0-fog.g);
	}
	
	vec2 metallicRoughness = texture2D(u_texMetallicRoughness, v_coord).bg;
	vec3 normal = normalize( texture2D(u_texNormal, v_coord).rgb * 2.0 - 1.0);
	
	// compute derivations of the world position
	vec3 p_dx = dFdx(v_view.xyz);
	vec3 p_dy = dFdy(v_view.xyz);
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
	vec3 col = base.rgb;
	gl_FragData[0] = vec4(col, 1.0);
	gl_FragData[1] = vec4(rim, shade, fog);
}