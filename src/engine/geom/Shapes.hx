package engine.geom;

@:structInit
@:publicFields
class Rectangle {
	var x:Float;
	var y:Float;
	var width:Int;
	var height:Int;

	var width_half(get, never):Float;
	var height_half(get, never):Float;

	var center_x(get, never):Float;
	var center_y(get, never):Float;

	var top(get, never):Float;
	var bottom(get, never):Float;
	var left(get, never):Float;
	var right(get, never):Float;

	private inline function get_top():Float {
		return y;
	}

	private inline function get_bottom():Float {
		return y + height;
	}

	private inline function get_left():Float {
		return x;
	}

	private inline function get_right():Float {
		return x + width;
	}

	private inline function get_center_x():Float {
		return x + (width / 2);
	}

	private inline function get_center_y():Float {
		return y + (height / 2);
	}

	private inline function get_width_half():Float {
		return width / 2;
	}

	private inline function get_height_half():Float {
		return height / 2;
	}

	public function is_point_inside(point_x:Float, point_y:Float):Bool{
		return is_point_inside_rectangle(point_x, point_y, x, y, width, height);
	}
}


/**
	Collision Detection functions ported from raylib rshapes.c
**/
function is_point_inside_rectangle(point_x:Float, point_y:Float, rect_x:Float, rect_y:Float, rect_width:Float, rect_height:Float):Bool {
	return ((point_x >= rect_x) && (point_x < (rect_x + rect_width)) && (point_y >= rect_y) && (point_y < (rect_y + rect_height)));
}

function is_point_inside_circle(point_x:Float, point_y:Float, circ_x:Float, circ_y:Float, circ_rad:Float):Bool {
	var distanceSquared = (point_x - circ_x) * (point_x - circ_x) + (point_y - circ_y) * (point_y - circ_y);
	return distanceSquared <= circ_rad * circ_rad;
}

function is_point_inside_triangle(point_x:Float, point_y:Float, t1_x:Float, t1_y:Float, t2_x:Float, t2_y:Float, t3_x:Float, t3_y:Float):Bool {
	var alpha = ((t2_y - t3_y) * (point_x - t3_x) + (t3_x - t2_x) * (point_y - t3_y)) / ((t2_y - t3_y) * (t1_x - t3_x) + (t3_x - t2_x) * (t1_y - t3_y));

	var beta = ((t3_y - t1_y) * (point_x - t3_x) + (t1_x - t3_x) * (point_y - t3_y)) / ((t2_y - t3_y) * (t1_x - t3_x) + (t3_x - t2_x) * (t1_y - t3_y));

	var gamma = 1.0 - alpha - beta;

	return ((alpha > 0) && (beta > 0) && (gamma > 0));
}

function is_point_inside_polygon(point_x:Float, point_y:Float, polygon:Array<Array<Float>>):Bool {
	var is_inside = false;
	if (polygon.length > 2) {
		for (i in 0...polygon.length) {
			var j = i + 1;
			if ((polygon[i][1] > point_y) != (polygon[j][1] > point_y)
				&& (point_x < (polygon[j][0] - polygon[i][0]) * (point_y - polygon[i][1]) / (polygon[j][1] - polygon[i][1]) + polygon[i][0])) {
				is_inside = !is_inside;
			}
		}
	}
	return is_inside;
}

function is_point_on_line(point_x:Float, point_y:Float, l1_x:Float, l1_y:Float, l2_x:Float, l2_y:Float, threshold:Int):Bool {
	var collision = false;

	var dxc = point_x - l1_x;
	var dyc = point_y - l1_y;
	var dxl = l2_x - l1_x;
	var dyl = l2_y - l1_y;
	var cross = dxc * dyl - dyc * dxl;

	if (Math.abs(cross) < (threshold * Math.max(Math.abs(dxl), Math.abs(dyl)))) {
		if (Math.abs(dxl) >= Math.abs(dyl)) {
			collision = (dxl > 0) ? ((l1_x <= point_x) && (point_x <= l2_x)) : ((l2_x <= point_x) && (point_x <= l1_x));
		} else {
			collision = (dyl > 0) ? ((l1_y <= point_y) && (point_y <= l2_y)) : ((l2_y <= point_y) && (point_y <= l1_y));
		}
	}

	return collision;
}
