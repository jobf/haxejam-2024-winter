package engine.body.physics;

import engine.body.physics.Physics.PhysicsInGrid;

/**
	This extension of the base movement adds extra functionality typically found in platformer physics

	- predictable jump variables : intuitively adjust the height and duration of a jump to derive y velocity
	- control jump descent : release the jump button before jump apex to descend early
	- faster jump descent : descend from jump apex faster than ascent

	- coyote time : allows jump to be performed a short time after leaving the edge of platform
	- jump buffer : allows jump button press to to be registered before touching ground

 **/
class PhysicsPlatformer extends PhysicsInGrid {
	public var jump_config(default, null):JumpConfig;

	/** y velocity of jump ascent. measured in tiles per step **/
	var velocity_ascent:Float;

	/** y velocity of jump descent, measured in tiles per step**/
	var velocity_descent:Float;

	/** gravity to apply during jump ascent, measured in tiles per step **/
	var gravity_ascent:Float;

	/** gravity to apply during jump descent, measured in tiles per step **/
	var gravity_descent:Float;

	/** game steps remaining until jump buffer time ends **/
	var buffer_step_count_remaining:Int = 0;

	/** game steps remaining until coyote time ends **/
	var coyote_steps_remaining:Int = 0;

	/** true during the ascent and descent of a jump **/
	var is_jump_in_progress:Bool = false;

	/** true when no vertical movement is possible towards floor **/
	var is_on_ground:Bool = true;

	public function new(grid_x:Int, grid_y:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		super(grid_x, grid_y, tile_size, has_wall_tile_at);
		jump_config = {}

		// y velocity is determined by jump velocity and gravity so set friction to 0
		velocity.friction_y = 0;
		
		// calculate gravity
		gravity_ascent = -(-2.0 * jump_config.height_tiles_max / (jump_config.ascent_step_count * jump_config.ascent_step_count));
		gravity_descent = -(-2.0 * jump_config.height_tiles_max / (jump_config.descent_step_count * jump_config.descent_step_count));

		// calculate velocity
		velocity_ascent = -((2.0 * jump_config.height_tiles_max) / jump_config.ascent_step_count);
		velocity_descent = Math.sqrt(2 * gravity_descent * jump_config.height_tiles_min);
	}

	/** called from jump button or key press **/
	public function press_jump() {
		// jump ascent phase can start if we are on the ground or coyote time did not finish

		var is_within_coyote_time = coyote_steps_remaining > 0;
		if (is_on_ground || is_within_coyote_time) {
			ascend();
		} else {
			// if jump was pressed but could not be performed begin jump buffer
			buffer_step_count_remaining = jump_config.buffer_step_count;
		}
	}

	/** called from jump button or key release **/
	public function release_jump() {
		descend();
	}

	/** begin jump ascent phase **/
	inline function ascend() {
		// set ascent velocity
		velocity.delta_y = velocity_ascent;

		// if we are in ascent phase then jump is in progress
		is_jump_in_progress = true;

		// reset coyote time because we left the ground with a jump
		coyote_steps_remaining = 0;
	}

	/** begin jump descent phase **/
	inline function descend() {
		// set descent velocity
		velocity.delta_y = velocity_descent;
	}

	function update() {
		/// jump logic
		/////////////

		// count down every step
		coyote_steps_remaining--;
		buffer_step_count_remaining--;

		if (is_on_ground) {
			// if we are on the ground then a jump is not in progress or has finished
			is_jump_in_progress = false;

			// reset coyote step counter every step that we are on the ground
			coyote_steps_remaining = jump_config.coyote_step_count;

			// jump ascent phase can be triggered if we are on the ground and jump buffer is in progress
			if (buffer_step_count_remaining > 0) {
				// trigger jump ascent phase
				ascend();
				// reset jump step counter because jump buffer has now ended
				buffer_step_count_remaining = 0;
			}
		}

		/// movement logic
		/////////////////

		// change position within grid cell by velocity
		update_velocity();

		// check for adjacent tiles
		update_neighbours();

		// apply gravity
		if (is_jump_in_progress) {
			// gravity has different values depending on jump phase
			// ascent phase if delta_y is negative (moving towards ceiling)
			// descent phase if delta_y is positive (moving towards floor)
			velocity.delta_y += velocity.delta_y <= 0 ? gravity_ascent : gravity_descent;
		} else {
			// use default gravity when jump is not in progress
			velocity.delta_y += velocity.gravity;
		}

		// stop movement if colliding with a tile
		update_collision();

		// if delta_y is 0 and there is a wall tile below then movement stopped
		// because we collided with the ground
		is_on_ground = velocity.delta_y == 0 && neighbours.is_wall_down;

		// update position within grid and cell
		update_position();
	}
}

@:structInit
class JumpConfig {
	/** maximum height of jump, measured in tiles **/
	public var height_tiles_max:Float = 7;

	/** minimum height of jump, measured in tiles **/
	public var height_tiles_min:Float = 2.5;

	/** duration of jump ascent time, measured in game update steps **/
	public var ascent_step_count = 20;

	/** duration of jump descent time, measured in game update steps **/
	public var descent_step_count = 12;

	/** duration of jump buffer time, measured in game steps**/
	public var buffer_step_count:Int = 15;

	/** duration of coyote time, measured in game steps**/
	public var coyote_step_count:Int = 5;
}
