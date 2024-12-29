package engine.graphics.elements;

import engine.geom.Shapes;
import hxmath.math.Vector2;
import peote.view.*;

class Basic implements Element {
	/** Position of the element on x axis. Relative to top left of Display.**/
	@posX public var x:Float;

	/** Position of the element on y axis. Relative to top left of Display.**/
	@posY public var y:Float;

	/** Size of the element on x axis. **/
	@sizeX @varying public var width:Int;

	/** Size of the element on y axis. **/
	@sizeY @varying public var height:Int;

	/** The pivot point around with the element will rotate on the x axis - 0.5 is the center. **/
	@pivotX @formula("width * pivot_x") public var pivot_x:Float = 0.5;

	/** The pivot point around with the element will rotate on the y axis - 0.5 is the center. **/
	@pivotY @formula("height * pivot_y") public var pivot_y:Float = 0.5;

	/** Degrees of rotation. **/
	@rotation public var angle:Float = 0.0;

	/** Tint the element with RGBA color. **/
	@color public var tint:Color = 0xf0f0f0ff;
	
	// @texTile public var tile:Int = 0

	public var filled:Basic;

	/** Auto-enable blend in the Program the element is rendered by (for alpha and more) **/
	var OPTIONS = {blend: true};

	/** 
		@param x the starting x position in the Display.
		@param y the starting y position in the Display.
		@param size the starting width and height.
		@param height (optional) the starting height, in case it is different to the width.
	**/
	public function new(x:Float, y:Float, size:Float, height:Null<Float> = null, tint:Color = 0xf0f0f0d0, is_centered:Bool=true) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		width = Std.int(size);
		this.height = Std.int(height ?? size);
		this.tint = tint;
		if(!is_centered){
			pivot_x = 0;
			pivot_y = 0;
		}
	}

	public var from:Vector2 = null;
	public var to:Vector2 = null;

	/** 
		Skews the shape to form a line. 
		@param is_origin_centered (optional) offset the center to the element mid point.
		@param thickness (optional) how many pixels thick is the line.
	**/
	public function to_line(x_start:Float, y_start:Float, x_end:Float, y_end:Float, is_origin_centered:Bool = true, thickness:Int = 1,
			angle_precalculated:Null<Float> = null):Array<Vector2> {
		if (is_origin_centered) {
			pivot_x = height * 0.5;
			pivot_y = pivot_x;
		} else {
			pivot_x = 0.0;
			pivot_y = 0.0;
		}

		x = x_start;
		y = y_start;
		height = thickness;

		var a = x_start - x_end;
		var b = y_start - y_end;

		width = Std.int(Math.sqrt(a * a + b * b)) + height;

		angle = angle_precalculated ?? Math.atan2(x_end - x_start, -(y_end - y_start)) * (180 / Math.PI) - 90;

		from = new Vector2(x_start, y_start);
		to = new Vector2(x_end, y_end);

		var x = Math.min(x_start, x_end);
		var y = Math.min(y_start, y_end);
		var w = Math.max(x_start, x_end) - x;
		var h = Math.max(y_start, y_end) - y;
		filled = new Basic(x + 2, y + 2, w - 4, h - 4, 0x70007000, false);

		return [from, to];
	}

	public function is_intersection(other:Basic):Bool 
	{
		var x1 = from.x;
		var y1 = from.y;
		var x2 = to.x;
		var y2 = to.y;

		var x3 = other.from.x;
		var y3 = other.from.y;
		var x4 = other.to.x;
		var y4 = other.to.y;
		
		// Calculate the determinant
		var det = (x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3);
  
		// If determinant is 0, the lines are parallel or coincident
		if (Std.int(det) == 0) {
			 return false;
		}
  
		// Calculate the parameters t and u
		var t = ((x3 - x1) * (y4 - y3) - (y3 - y1) * (x4 - x3)) / det;
		var u = -((x1 - x3) * (y2 - y1) - (y1 - y3) * (x2 - x1)) / det;
  
		// Check if t and u are between 0 and 1 (inclusive), meaning the segments intersect
		return t >= 0 && t <= 1 && u >= 0 && u <= 1;
	}

	public function is_inside_area(point_x:Float, point_y:Float):Bool
	{
		return is_point_inside_rectangle(point_x, point_y, x, y, width, height);
	}

	public static function init_buffer(display:Display, size:Int = 256, init:Program->Void = null) {
		var buffer = new Buffer<Basic>(size, size);
		var program = new Program(buffer);
		if (init != null) {
			init(program);
		}
		program.addToDisplay(display);
		return buffer;
	}
}
