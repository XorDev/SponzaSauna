attribute vec3 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_coord;
varying float v_depth;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
	vec4 view = gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Position, 1);
	
	v_coord = in_TextureCoord;
	v_depth = view.z;
}