package engine;

/** accurate linear interpolation **/
inline function lerp(a:Float, b:Float, t:Float):Float {
	return (1.0 - t) * a + b * t;
}


/** fast, imprecise linear interpolation **/
inline function lerp_fast(a:Float, b:Float, t:Float):Float {
	return a + (b - a) * t;
}


inline function inverse_lerp(a:Float, b:Float, v:Float):Float {
	return (v - a) / (b - a);
}

inline function remap(i_min:Float, i_max:Float, o_min:Float, o_max:Float, v:Float):Float{
	var t = inverse_lerp(i_min, i_max, v);
	return lerp(o_min, o_max, t);
}
