package engine.body;

import engine.body.skin.Skin;
import engine.body.physics.Physics;

@:publicFields
abstract class Body<TSkin:Skin, TPhysics:Physics> {
    var skin(default, null):TSkin;
    var physics(default, null):TPhysics;

    abstract private function on_collide(side_x:Int, side_y:Int):Void;
        
    function new(skin:TSkin, physics:TPhysics) {
        this.skin = skin;
        this.physics = physics;
        this.physics.events.on_collide = on_collide;
    }

    function update() {
        physics.update();
    }

    function draw(frame_ratio:Float) {
        var x = lerp(physics.position.x_previous, physics.position.x, frame_ratio);
        var y = lerp(physics.position.y_previous, physics.position.y, frame_ratio);
        skin.move(x, y);
        
        var r = lerp(physics.position.r_previous, physics.position.r, frame_ratio);
        skin.rotate(r);

    }
}

@:publicFields
abstract class State<TSkin:Skin, TPhysics:Physics>
{
	var actor: Body<TSkin, TPhysics>;

	function new(actor: Body<TSkin, TPhysics>)
	{
		this.actor = actor;
		on_state_init();
	}

	abstract function on_state_init(): Void;

	abstract function on_state_enter(): Void;

	abstract function on_state_update(): Void;
}

abstract class BodyCache<TSkin:Skin, TPhysics:Physics> extends ObjectCache<Body<TSkin, TPhysics>>
{
	// abstract private function create_item():Body<TSkin, TPhysics>;
	// abstract private function on_cache_item(item:Body<TSkin, TPhysics>):Void;
	
}
