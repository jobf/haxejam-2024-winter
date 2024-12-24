package engine.graphics;

import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

@:structInit
/**
	Configure Camera scroll boundaries and dead zone.
	All values relate to pixel positions in the world.
	Camera will not scroll outside boundaries.
	Camera will only scroll if target is outside dead zone.
**/
class ScrollConfig {
	/** width of viewable area, e.g. the window**/
	public var view_width:Int;

	/** height of viewable area, e.g. the window**/
	public var view_height:Int;

	/**left side of view cannot be scrolled beyond this**/
	public var boundary_left:Int = 0;

	/**right side of view cannot be scrolled beyond this**/
	public var boundary_right:Int = 0;

	/**top of view cannot be scrolled beyond this**/
	public var boundary_ceiling:Int = 0;

	/**bottom of view cannot be scrolled beyond this**/
	public var boundary_floor:Int = 0;

	/**central position of dead zone x**/
	public var zone_center_x:Int = 0;

	/**central position of dead zone y**/
	public var zone_center_y:Int = 0;

	/**width of dead zone**/
	public var zone_width:Int = 0;

	/**width of dead zone**/
	public var zone_height:Int = 0;

	/** how much to relax camera scrolling speed (0.0 - 1.0) **/
	public var smoothing:Float = 0.0;
}

/**
	Used to control display offsets to scroll the area is viewed;
**/
class Camera {
	public var scroll(default, null):ScrollConfig;
	public var zoom(get, set):Float;

	/**the display to be offset**/
	var display:Display;

	var view_center_x:Float;
	var view_center_y:Float;

	var zone_width_offset:Float;
	var zone_height_offset:Float;
	var zone_left:Float;
	var zone_ceiling:Float;
	var zone_right:Float;
	var zone_floor:Float;

	var debug:CameraDebug;
	var is_debug_visible:Bool = false;
	var offset_x:Int = 0;
	var offset_y:Int = 0;
	var previous_offset_x:Float = 0;
	var previous_offset_y:Float = 0;

	public function new(display:Display, scrolling:ScrollConfig) {
		this.display = display;
		this.scroll = scrolling;
		debug = new CameraDebug(display);
	}

	public function center_on(x:Float, y:Float) {
		scroll.zone_center_x = Std.int(x);
		scroll.zone_center_y = Std.int(y);

		center_camera_x(scroll.zone_center_x);
		center_camera_y(scroll.zone_center_y);

		if (is_debug_visible) {
			debug.update(scroll);
		}
	}

	public function follow_target(target_left:Float, target_right:Float, target_ceiling:Float, target_floor:Float) {
		previous_offset_x = offset_x;
		previous_offset_y = offset_y;

		/*
			update dead zone limits
		 */
		zone_width_offset = scroll.zone_width / 2;
		zone_height_offset = scroll.zone_height / 2;
		zone_left = scroll.zone_center_x - zone_width_offset;
		zone_ceiling = scroll.zone_center_y - zone_height_offset;
		zone_right = scroll.zone_center_x + zone_width_offset;
		zone_floor = scroll.zone_center_y + zone_height_offset;

		/* 
			update camera if target is outsize dead zone
		 */
		if (target_left <= zone_left) {
			scroll.zone_center_x -= Std.int((zone_left - target_left) * (1.0 - scroll.smoothing));
			center_camera_x(scroll.zone_center_x);
		}
		if (target_ceiling <= zone_ceiling) {
			scroll.zone_center_y -= Std.int((zone_ceiling - target_ceiling) * (1.0 - scroll.smoothing));
			center_camera_y(scroll.zone_center_y);
		}
		if (target_right >= zone_right) {
			scroll.zone_center_x += Std.int((target_right - zone_right) * (1.0 - scroll.smoothing));
			center_camera_x(scroll.zone_center_x);
		}
		if (target_floor >= zone_floor) {
			scroll.zone_center_y += Std.int((target_floor - zone_floor) * (1.0 - scroll.smoothing));
			center_camera_y(scroll.zone_center_y);
		}

		/*
			update visible dead zone debugger
		 */
		if (is_debug_visible) {
			debug.update(scroll);
		}
	}

	public function draw(frame_ratio:Float) {
		debug.draw(frame_ratio);
		display.xOffset = lerp(previous_offset_x, offset_x, frame_ratio);
		display.yOffset = lerp(previous_offset_y, offset_y, frame_ratio);
	}

	/**toggle visibility of dead zone debugger**/
	public function toggle_debug() {
		is_debug_visible = !is_debug_visible;
		debug.is_visible = is_debug_visible;
	}

	/**center the camera x axis on the target, will stay within scroll boundaries**/
	inline function center_camera_x(target:Float) {
		// determine view center
		view_center_x = (scroll.view_width / 2) / zoom;

		// keep within boundary left
		var x_scroll_min = view_center_x;
		if (target < x_scroll_min) {
			view_center_x -= (x_scroll_min - target);
		}

		// keep within boundary right
		var x_scroll_max = (scroll.boundary_right - view_center_x);
		if (target > x_scroll_max) {
			view_center_x += (target - x_scroll_max);
		}

		// update display offset to move the viewed area
		offset_x = -Std.int((target - view_center_x) * zoom);
		// display.xOffset = -Std.int((target - view_center_x) * zoom);
	}

	/**center the camera y axis on the target, will stay within scroll boundaries**/
	inline function center_camera_y(target:Float) {
		// determine view center
		view_center_y = (scroll.view_height / 2) / zoom;

		// keep within boundary ceiling
		var y_scroll_min = view_center_y;
		if (target < y_scroll_min) {
			view_center_y -= (y_scroll_min - target);
		}

		// keep within boundary floor
		var y_scroll_max = (scroll.boundary_floor - view_center_y);
		if (target > y_scroll_max) {
			view_center_y += (target - y_scroll_max);
		}

		// update display offset to move the viewed area
		offset_y = -Std.int((target - view_center_y) * zoom);
		// display.yOffset = -Std.int((target - view_center_y) * zoom);
	}

	function get_zoom():Float {
		return display.zoom;
	}

	function set_zoom(value:Float):Float {
		display.zoom = value;
		return display.zoom;
	}
}

class CameraDebug {
	var buffer:Buffer<Basic>;
	var program:Program;
	var debug_element:Basic;
	var position_x:Float;
	var position_y:Float;
	var position_x_previous:Float;
	var position_y_previous:Float;

	var tint_visible:Int = 0x00e5ff20;
	var tint_hidden:Int = 0x00000000;

	public function new(display:Display) {
		buffer = new Buffer<Basic>(1);
		program = new Program(buffer);
		program.addToDisplay(display);
		position_x = -10;
		position_y = -10;
		position_x_previous = position_x;
		position_y_previous = position_y;
		debug_element = new Basic(position_x, position_y, 1);
		debug_element.tint = tint_visible;
		buffer.addElement(debug_element);
	}

	inline public function update(scroll:ScrollConfig) {
		position_x_previous = position_x;
		position_y_previous = position_y;
		position_x = scroll.zone_center_x;
		position_y = scroll.zone_center_y;

		debug_element.width = scroll.zone_width;
		debug_element.height = scroll.zone_height;
	}

	public function draw(frame_ratio:Float) {
		if (is_visible) {
			debug_element.x = lerp(position_x_previous, position_x, frame_ratio);
			debug_element.y = lerp(position_y_previous, position_y, frame_ratio);
			buffer.updateElement(debug_element);
		}
	}

	public var is_visible(get, set):Bool;

	function get_is_visible():Bool {
		return debug_element.tint == tint_visible;
	}

	function set_is_visible(is_visible:Bool):Bool {
		debug_element.tint = is_visible ? tint_visible : tint_hidden;
		buffer.updateElement(debug_element);
		return is_visible;
	}
}
