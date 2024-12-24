package engine.body.physics;

/**
	Based on deepnight blog posts from 2013
	movement logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-1-basics/
	overlap logic - https://deepnight.net/tutorial/a-simple-platformer-engine-part-2-collisions/
**/
class PhysicsInGrid extends Physics {

	/** the neighbouring tiles in the grid **/
	var neighbours(default, null):Neighbours;

	private var has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool;

	/**
		@param grid_x the starting x co-ordinate in the grid
		@param grid_y the starting y co-ordinate in the grid
		@param tile_size the size of each grid cell (squared)
		@param has_wall_tile_at a callback which is used to determine whether a co-ordinate has a solid tile
	**/
	function new(grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		
		super(grid_x, grid_y, tile_size);

		neighbours = {}
		
		this.has_wall_tile_at = has_wall_tile_at;
	}

	function update() {
		// change position within grid cell by velocity
		update_velocity();

		// check for adjacent tiles
		update_neighbours();

		// apply gravity
		velocity.delta_y += velocity.gravity;

		// stop movement if colliding with a tile
		update_collision();

		// update position within grid and cell
		update_position();
	}


	inline function update_neighbours() {
		neighbours.is_wall_left = has_wall_tile_at(position.grid_x - 1, position.grid_y);
		neighbours.is_wall_right = has_wall_tile_at(position.grid_x + 1, position.grid_y);
		neighbours.is_wall_up = has_wall_tile_at(position.grid_x, position.grid_y - 1);
		neighbours.is_wall_down = has_wall_tile_at(position.grid_x, position.grid_y + 1);
	}

	inline function update_collision() {
		// Left collision
		if (position.grid_cell_ratio_x < size.edge_left && neighbours.is_wall_left) {
			position.grid_cell_ratio_x = size.edge_left; // clamp position
			if (events.on_collide != null) {
				events.on_collide(-1, 0);
			}
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Right collision
		if (position.grid_cell_ratio_x > size.edge_right && neighbours.is_wall_right) {
			position.grid_cell_ratio_x = size.edge_right; // clamp position
			if (events.on_collide != null) {
				events.on_collide(1, 0);
			}
			velocity.delta_x = 0; // stop horizontal movement
		}

		// Ceiling collision
		if (position.grid_cell_ratio_y < size.edge_top && neighbours.is_wall_up) {
			position.grid_cell_ratio_y = size.edge_top; // clamp position
			if (events.on_collide != null) {
				events.on_collide(0, -1);
			}
			velocity.delta_y = 0; // stop vertical movement
		}

		// Floor collision
		if (position.grid_cell_ratio_y > size.edge_bottom && neighbours.is_wall_down) {
			position.grid_cell_ratio_y = size.edge_bottom; // clamp position
			if (events.on_collide != null) {
				events.on_collide(0, 1);
			}
			velocity.delta_y = 0; // stop vertical movement
		}
	}
}


@:structInit
@:publicFields
class Neighbours {
	var is_wall_left:Bool = false;
	var is_wall_right:Bool = false;
	var is_wall_up:Bool = false;
	var is_wall_down:Bool = false;
}
