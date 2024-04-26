var _w,_h;
_w = window_get_width();
_h = window_get_height();
SurfaceCheck(application_surface, _w, _h);

var _size = global.sauna_depth_size;
global.sauna_depth_surf = SurfaceCheck(global.sauna_depth_surf, _size, _size, surface_r32float);
global.sauna_surf_color = SurfaceCheck(global.sauna_surf_color, _w, _h);
global.sauna_surf_shade = SurfaceCheck(global.sauna_surf_shade, _w, _h);

gpu_push_state();
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);
gpu_set_tex_repeat(true);
draw_clear(c_black);
matrix_set(matrix_world, modelMatrix);

surface_set_target(global.sauna_depth_surf);
draw_clear(9999);
gpu_set_blendenable(false);
matrix_set(matrix_projection,global.sauna_depth_proj);
matrix_set(matrix_view,global.sauna_depth_view);
shader_set(sauna_shd_depth);
model.Submit();
shader_reset();
gpu_set_blendenable(true);
surface_reset_target();

surface_set_target(global.sauna_surf_color);
draw_clear(0);
surface_reset_target();

surface_set_target(global.sauna_surf_shade);
draw_clear_alpha(0,0);
surface_reset_target();

surface_set_target_ext(0, global.sauna_surf_color);
surface_set_target_ext(1, global.sauna_surf_shade);
gpu_set_blendenable(false);
camera_apply(camera);
shader_set(sauna_shd_shadow);
shader_set_uniform_f(global.sauna_u_fog, global.sauna_fog_dense, global.sauna_fog_height);
shader_set_uniform_f(global.sauna_u_cam, x,y,z);
shader_set_uniform_matrix_array(global.sauna_u_shadow_proj, global.sauna_depth_proj);
shader_set_uniform_matrix_array(global.sauna_u_shadow_view, global.sauna_depth_view);
texture_set_stage(global.sauna_u_shadow, surface_get_texture(global.sauna_depth_surf));
gpu_set_tex_filter_ext(global.sauna_u_noise, false);
texture_set_stage(global.sauna_u_noise, global.sauna_t_noise);
model.Submit();
shader_reset();
gpu_set_blendenable(true);
surface_reset_target();

matrix_set(matrix_world, global.sauna_mat_identity);

shader_set(sauna_shd_post);
texture_set_stage(global.sauna_u_shade, surface_get_texture(global.sauna_surf_shade));
draw_surface(global.sauna_surf_color,0,0);
shader_reset();
gpu_pop_state();

if (screenshotMode)
{
	exit;
}

var _windowWidth = window_get_width();

var _text = "Press Space to set light";
draw_set_color(c_silver);

draw_text(_windowWidth/2 - string_width(_text)/2, 8, _text);

_text = "FPS: " + string(fps) + " (" + string(fps_real) + ")";
draw_text(_windowWidth - string_width(_text) - 8, 8, _text);

gui.SetPosition(8, 8)
	.Checkbox(guiShow, {
		Label: "Show UI (F1)",
		OnChange: method(self, function (_value) { guiShow = _value; }),
	})
	.Newline();

if (guiShow)
{
	gui.Slider("camera-fov", fov, {
			Label: "Camera FoV",
			Min: 1,
			Max: 90,
			Round: true,
			OnChange: method(self, function (_value) { fov = _value; }),
		})
		.Newline()
	gui.Slider("fog-density", global.sauna_fog_dense, {
		Label: "Fog Density",
		Min: 0.1,
		Max: 3,
		Round: false,
		OnChange: method(self, function (_value) { global.sauna_fog_dense = _value; }),
	})
	.Newline()
	gui.Slider("fog-height", global.sauna_fog_height, {
		Label: "Fog Height",
		Min: 0,
		Max: 10,
		Round: false,
		OnChange: method(self, function (_value) { global.sauna_fog_height = _value; }),
	})
	.Newline()
	gui.Slider("light-fov", global.sauna_light_fov, {
		Label: "Light FOV",
		Min: 1,
		Max: 150,
		Round: false,
		OnChange: method(self, function (_value) { global.sauna_light_fov = _value; global.sauna_depth_proj = matrix_build_projection_perspective_fov(global.sauna_light_fov,1,1,10000);}),
	})
	.Newline()
	;
	;
}

if keyboard_check(ord("1")) draw_surface_ext(global.sauna_depth_surf,8,8,0.2,0.2,0,#101010,1);