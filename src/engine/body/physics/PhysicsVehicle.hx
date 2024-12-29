package engine.body.physics;

import engine.body.physics.Physics;


class PhysicsVehicle extends Physics {
	var is_accelerating:Bool = false;
	var is_steering:Bool = false;
	var steering_direction:Int = 0;
	var acceleration:Acceleration = {
		friction: 0.2,
		spin: 1.2,
		thrust: 0.3,
		max_delta_r: 3.8,
		max_delta_x: 1.2,
		max_delta_y: 35.2,
	};

	public var thrust_delta:Float = 0;

	public function new(x:Float, y:Float, size:Int) {
		super(0, 0, size);
		velocity.friction_x = 0;
	}

	public function update() {
		position.r_previous = position.r;
		position.x_previous = position.x;
		position.y_previous = position.y;

		if (is_steering) {
			velocity.delta_r += acceleration.spin * steering_direction;
		}

		if (velocity.delta_r > 0) {
			if (velocity.delta_r > acceleration.max_delta_r) {
				velocity.delta_r = acceleration.max_delta_r;
			}
			velocity.delta_r -= acceleration.friction;
			if (velocity.delta_r < 0.001) {
				velocity.delta_r = 0;
			}
		}

		if (velocity.delta_r < 0) {
			if (velocity.delta_r < -acceleration.max_delta_r) {
				velocity.delta_r = -acceleration.max_delta_r;
			}
			velocity.delta_r += acceleration.friction;
			if (velocity.delta_r > -0.001) {
				velocity.delta_r = 0;
			}
		}
		// if(acceleration.spin < 0) acceleration.spin = 0;

		if (is_accelerating) {
			thrust_delta += acceleration.thrust;
		}

		if (thrust_delta > acceleration.max_delta_y) {
			thrust_delta = acceleration.max_delta_y;
		}

		thrust_delta -= acceleration.friction;
		if (thrust_delta < 0.001)
			thrust_delta = 0;

		var radians = position.r * (Math.PI / 180);
		velocity.delta_x = Math.sin(radians) * thrust_delta;
		velocity.delta_y = -Math.cos(radians) * thrust_delta;
		position.r += velocity.delta_r;
		position.x += velocity.delta_x;
		position.y += velocity.delta_y;
	}

	public function start_steer(direction:Int):Void{
		is_steering = true;
		steering_direction = direction;
	}

	public function stop_steer():Void{
		is_steering = false;
		steering_direction = 0;
	}

	public function start_thrust():Void{
		is_accelerating = true;
	}

	public function stop_thrust():Void{
		is_accelerating = false;
	}

}