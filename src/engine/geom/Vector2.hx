package engine.geom;

import hxmath.math.Vector2;

@:publicFields
class Vector2Extend {
	static function cross(a:Vector2, b:Vector2):Float {
		return a.x * b.y - a.y * b.x;
	}
}

/**
	distance between 2 points 
**/
inline function distance_to_point(x_a:Float, y_a:Float, x_b:Float, y_b:Float):Float {
	var x_d = x_a - x_b;
	var y_d = y_a - y_b;
	return Math.sqrt(x_d * x_d + y_d * y_d);
}
