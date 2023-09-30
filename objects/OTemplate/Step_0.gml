var _mouseX = window_mouse_get_x();
var _mouseY = window_mouse_get_y();

if (mouse_check_button(mb_right))
{
	direction += (mouseLastX - _mouseX);
	directionUp = clamp(directionUp + (mouseLastY - _mouseY), -89.0, 89.0);
}
if mouse_check_button_pressed(mb_right) window_set_cursor(cr_cross);
if mouse_check_button_released(mb_right) window_set_cursor(cr_default);

mouseLastX = _mouseX;
mouseLastY = _mouseY;

var _speed = keyboard_check(vk_shift) ? 0.4 : 0.1;

if (keyboard_check(ord("W")))
{
	x += lengthdir_x(_speed, direction);
	y += lengthdir_y(_speed, direction);
}

if (keyboard_check(ord("S")))
{
	x -= lengthdir_x(_speed, direction);
	y -= lengthdir_y(_speed, direction);
}

if (keyboard_check(ord("A")))
{
	x += lengthdir_x(_speed, direction + 90.0);
	y += lengthdir_y(_speed, direction + 90.0);
}

if (keyboard_check(ord("D")))
{
	x += lengthdir_x(_speed, direction - 90.0);
	y += lengthdir_y(_speed, direction - 90.0);
}

z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;

var _directionX = dcos(direction);
var _directionY = -dsin(direction);
var _directionZ = dtan(directionUp);
var _view = matrix_build_lookat(
	x, y, z,
	x + _directionX,
	y + _directionY,
	z + _directionZ,
	0.0, 0.0, 1.0);
	
var _aspectRatio = window_get_width() / window_get_height();
var _proj = matrix_build_projection_perspective_fov(
	-fov, -_aspectRatio, 0.1, clipFar);

camera_set_view_mat(camera, _view);

if keyboard_check(vk_space)
{
	global.sauna_depth_view = _view;
	global.sauna_depth_mat = matrix_multiply(global.sauna_depth_view, global.sauna_depth_proj);
}

camera_set_proj_mat(camera, _proj);

if (keyboard_check_pressed(vk_f1))
{
	guiShow = !guiShow;
}

if (keyboard_check_pressed(vk_f2))
{
	screenshotMode = !screenshotMode;
}

gui.Update();
