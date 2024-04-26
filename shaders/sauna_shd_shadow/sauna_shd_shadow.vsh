attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec2 v_coord;
varying vec3 v_normal;
varying vec4 v_world;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
	
	v_coord = in_TextureCoord;
	v_normal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0)).xyz;
	v_world = gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1);
}