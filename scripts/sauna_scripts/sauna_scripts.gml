function sauna_init(res)
{
	global.sauna_surf_color = -1;
	global.sauna_surf_shade = -1;

	global.sauna_light_fov = 90;

	global.sauna_mat_identity = matrix_build_identity();
	global.sauna_depth_view = matrix_build_lookat(0,0,0,0,0,0,0,0,1);
	global.sauna_depth_proj = matrix_build_projection_perspective_fov(global.sauna_light_fov,1,1,10000);
	global.sauna_depth_size = res;
	global.sauna_depth_surf = -1;

	global.sauna_fog_dense = 1;
	global.sauna_fog_height = 0;

	global.sauna_u_fog = shader_get_uniform(sauna_shd_shadow, "u_fog");
	global.sauna_u_cam = shader_get_uniform(sauna_shd_shadow, "u_cam");
	global.sauna_u_shadow = shader_get_sampler_index(sauna_shd_shadow, "u_shadow");
	global.sauna_u_noise = shader_get_sampler_index(sauna_shd_shadow, "u_noise");
	global.sauna_u_shadow_view = shader_get_uniform(sauna_shd_shadow, "u_shadow_view");
	global.sauna_u_shadow_proj = shader_get_uniform(sauna_shd_shadow, "u_shadow_proj");

	global.sauna_u_shade = shader_get_sampler_index(sauna_shd_post, "u_shade");

	global.sauna_t_noise = sprite_get_texture(spr_noise,0);
	gpu_set_tex_repeat_ext(global.sauna_u_noise, true);
}

function sauna_clean()
{
	surface_free(global.sauna_surf_color);
	surface_free(global.sauna_surf_shade);
	surface_free(global.sauna_depth_surf);	
}