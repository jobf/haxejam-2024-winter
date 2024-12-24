package engine.actor;

import engine.body.physics.PhysicsVehicle;
import engine.body.Body;
import engine.body.skin.Skin;

abstract class Vehicle<S:Skin> extends Body<S, PhysicsVehicle> {
	abstract function change_direction_x(direction:Int):Void;

	abstract function change_direction_y(direction:Int):Void;

	abstract function stop_x():Void;

	abstract function stop_y():Void;

	abstract function hold_trigger():Void;

	abstract function release_trigger():Void;
}
