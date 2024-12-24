package engine.body.physics;

/**
	This is the base class for Physics contains logic for moving through a tile map
**/
@:publicFields
abstract class Physics {
	/** position within the grid **/
	var position(default, null):Position;

	/** dimensions for interacting with the grid **/
	var size(default, null):Dimensions;

	/** speed of movement through the grid **/
	var velocity(default, null):Velocity;

	/** callbacks for significant events **/
	var events(default, null):Events;


	/**
		@param grid_x the starting x co-ordinate in the grid
		@param grid_y the starting y co-ordinate in the grid
		@param tile_size the size of each grid cell (squared)
	**/
	function new(grid_x:Int, grid_y:Int, tile_size:Int) {
		var grid_cell_ratio_x = 0.5;
		var grid_cell_ratio_y = 0.5;

		var x = (grid_x + grid_cell_ratio_x) * tile_size;
		var y = (grid_y + grid_cell_ratio_y) * tile_size;

		position = {
			grid_x: grid_x,
			grid_y: grid_y,
			grid_cell_ratio_x: grid_cell_ratio_x,
			grid_cell_ratio_y: grid_cell_ratio_y,
			x: x,
			y: y,
			x_previous: x,
			y_previous: y
		}

		size = {
			tile_size: tile_size,
			radius: tile_size / 2
		}

		velocity = {}

		
		events = {}

	}

	/** 
		Relocate to a position in the world instantly. Does not traverse the grid but grid positions will be updated accordingly.
		@param x The pixel position of x to move to, in world co-ordinates
		@param y The pixel position of y to move to, in world co-ordinates
	**/
	inline function teleport_to(x:Float, y:Float) {
		position.x = x;
		position.y = y;

		position.x_previous = x;
		position.y_previous = y;
		// calculate grid co-ordinates by using the tile size
		position.grid_x = Std.int(x / size.tile_size);
		position.grid_y = Std.int(y / size.tile_size);

		// center to the grid cell
		position.grid_cell_ratio_x = 0.5;
		position.grid_cell_ratio_y = 0.5;
	}

	/** Check if the other Physics overlaps this **/
	inline function overlaps(other:Physics):Bool {
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return distance_squared <= max_distance * max_distance;
	}

	/** Check if the other Physics overlaps this and return the size of the overlap in pixels **/
	inline function overlaps_by(other:Physics):Float {
		var max_distance = size.radius + other.size.radius;
		var distance_squared = (other.position.x
			- position.x) * (other.position.x - position.x)
			+ (other.position.y - position.y) * (other.position.y - position.y);
		return (max_distance * max_distance) - distance_squared;
	}

	/** 
		This function is called once per step of the physics simulation.
		It does not have a predefined implementation, instead allowing for custom logic to be formed using the provided functions in this class or completely custom implementations.
	**/
	abstract function update():Void;

	/** Applies **/
	inline function update_velocity() {
		position.grid_cell_ratio_x += velocity.delta_x;
		velocity.delta_x *= (1.0 - velocity.friction_x);
		position.grid_cell_ratio_y += velocity.delta_y;
		velocity.delta_y *= (1.0 - velocity.friction_y);
	}


	inline function update_position() {
		// advance position.grid position if crossing edge
		while (position.grid_cell_ratio_x > 1) {
			position.grid_cell_ratio_x--;
			position.grid_x++;
		}
		while (position.grid_cell_ratio_x < 0) {
			position.grid_cell_ratio_x++;
			position.grid_x--;
		}

		// resulting position
		position.x = Math.floor((position.grid_x + position.grid_cell_ratio_x) * size.tile_size);

		// advance position.grid position if crossing edge
		while (position.grid_cell_ratio_y > 1) {
			position.grid_y++;
			position.grid_cell_ratio_y--;
		}
		while (position.grid_cell_ratio_y < 0) {
			position.grid_y--;
			position.grid_cell_ratio_y++;
		}

		// resulting position
		position.y = Math.floor((position.grid_y + position.grid_cell_ratio_y) * size.tile_size);
	}
}

@:structInit
@:publicFields
class Position {
	// tile map coordinates
	var grid_x:Int;
	var grid_y:Int;

	// ratios are 0.0 to 1.0  (position inside grid cell)
	var grid_cell_ratio_x:Float;
	var grid_cell_ratio_y:Float;

	// previous pixel coordinates
	var x_previous:Float;
	var y_previous:Float;

	// current pixel coordinates
	var x:Float;
	var y:Float;

	// rotation
	var r:Float = 0;
	var r_previous:Float = 0;
}

@:structInit
@:publicFields
class Velocity {
	// applied to grid cell ratio each frame
	var delta_x:Float = 0;
	var delta_y:Float = 0;
	// applied to rotation each frame
	var delta_r:Float = 0;

	// friction applied each frame 0.0 for none, 1.0 for maximum
	var friction_x:Float = 0.10;
	var friction_y:Float = 0.06;

	// applied to delta_y each frame
	var gravity:Float = 0.05;

}


@:structInit
@:publicFields
class Acceleration {
	var thrust:Float = 0.4;
	var spin:Float = 0.4;
	var friction:Float = 0.8;
	var max_delta_x:Float = 999999;
	var max_delta_y:Float = 999999;
	var max_delta_r:Float = 10;
}

@:structInit
@:publicFields
class Dimensions {
	var edge_left:Float = 0.3;
	var edge_right:Float = 0.7;
	var edge_top:Float = 0.2;
	var edge_bottom:Float = 0.5;
	var tile_size:Int;
	var radius:Float;
}

@:structInit
@:publicFields
class Events {
	var on_collide:(side_x:Int, side_y:Int) -> Void = null;
}
