package game;

import engine.body.physics.PhysicsVehicle;
import engine.graphics.elements.Tile;
import engine.graphics.elements.Basic;
import peote.view.*;
import engine.actor.Projectile;
import engine.ObjectCache;
import engine.body.Body;
import engine.body.skin.SkinBasic;
import engine.actor.Vehicle;

using StringTools;

var RADIANS = Math.PI / 180;

class SkinBoat extends SkinBasic
{
	var pointer:Basic;
	var side_left:Basic;
	var side_right:Basic;
	var side_left_front:Basic;
	var side_right_front:Basic;
	var tip:Basic;
	var sprite:Tile;

	public function new(x:Float, y:Float, size:Float) {
		super(x, y, size);
		pointer = new Basic(x, y, 1);
		side_left = new Basic(x, y, 1);
		var boat_bits = 0x00;
		side_right = new Basic(x, y, 1);
		side_left_front = new Basic(x, y, 1);
		side_right_front = new Basic(x, y, 1);
		pointer.tint.a = boat_bits;
		element.tint.a = boat_bits;
		side_left.tint.a = boat_bits;
		side_left_front.tint.a = boat_bits;
		side_right.tint.a = boat_bits;
		side_right_front.tint.a = boat_bits;
		sprite = new Tile(x, y, 175, 0);
		sprite.pivot_y = 0.82;
		sprite.tint = Color.GREY6;
		// pointer.to_line(x, y, x + 200, y + 200);
		pointer.to_line(x, y, x + length, y + length, false);

		var r = pointer.angle * RADIANS;
		var tip_x = x + length * Math.cos(r);
		var tip_y = x + length * Math.sin(r);
		tip = new Basic(tip_x, tip_y, 10, 10,  0xf000f005);
		tip.angle = 45;

		//left side
		var r = pointer.angle * RADIANS;
		var tip_x = x + length * Math.cos(r);
		var tip_y = x + length * Math.sin(r);
		// tip = new Basic(tip_x, tip_y, 10, 10,  0xf000f050);
		tip.angle = 45;

		
	}

	override public function add_to_buffer(buffer:Buffer<Basic>){
		super.add_to_buffer(buffer);
		buffer.addElement(pointer);
		buffer.addElement(tip);
		buffer.addElement(side_left);
		buffer.addElement(side_right);
		buffer.addElement(side_left_front);
		buffer.addElement(side_right_front);
	}

	var length = 130;
	override public function move(x:Float, y:Float) {
		super.move(x, y);
		sprite.x = x;
		sprite.y = y;

		var r = (element.angle - 90) * RADIANS;
		var tip_x = element.x + (length * Math.cos(r) );
		var tip_y = element.y + (length * Math.sin(r) );
		tip.x = tip_x;
		tip.y = tip_y;

		pointer.to_line(element.x, element.y, tip.x, tip.y, false);
		
		var r = (element.angle - 90 - 45) * RADIANS;
		var tip_x = element.x + (length * 0.37 * Math.cos(r) );
		var tip_y = element.y + (length * 0.37 * Math.sin(r) );
		side_left.to_line(element.x, element.y, tip_x, tip_y, false);
		
		var r = (element.angle - 90 + 45) * RADIANS;
		var tip_x = element.x + (length * 0.37 * Math.cos(r) );
		var tip_y = element.y + (length * 0.37 * Math.sin(r) );
		side_right.to_line(element.x, element.y, tip_x, tip_y, false);



		var r = (element.angle - 90 - 15) * RADIANS;
		var tip_x = element.x + (length * 0.77 * Math.cos(r) );
		var tip_y = element.y + (length * 0.77 * Math.sin(r) );
		side_left_front.to_line(element.x, element.y, tip_x, tip_y, false);
		
		var r = (element.angle - 90 + 15) * RADIANS;
		var tip_x = element.x + (length * 0.77 * Math.cos(r) );
		var tip_y = element.y + (length * 0.77 * Math.sin(r) );
		side_right_front.to_line(element.x, element.y, tip_x, tip_y, false);
	}

	override public function rotate(angle:Float) {
		super.rotate(angle);
		sprite.angle = angle;
		pointer.angle = this.element.angle - 90;
		tip.angle = pointer.angle - 45;
	}
}

class Boat extends Vehicle<SkinBoat> {
	var cool_down:Int = 6;
	var cool_down_count:Int = 0;
	var is_trigger_held:Bool = false;
	var states:Map<BoatState, State<SkinBoat, PhysicsVehicle>> = [];
	var init_x:Float;
	var init_y:Float;
	var placement_x:Int;
	var placement_y:Int;
	var thrust:Float = 0;
	var state:State<SkinBoat, PhysicsVehicle>;
	var overlapping_for:Int = 0;

	function on_collide(side_x:Int, side_y:Int) {}

	var projectiles:ObjectCache<Projectile>;
	var path:Array<Basic>;

	public function new(column:Int, row:Int, size:Int, space:Int, buffer:Buffer<Basic>, projectiles:ObjectCache<Projectile>) {
		state = new BoatDoNothin(this);
		this.states = [
			IDLE => state,
			EXPIRED => state,
		];
		this.projectiles = projectiles;
		this.placement_x = (space * column);
		this.placement_y = (space * row);
		var x = placement_x;
		var y = placement_y;
		var skin = new SkinBoat(x, y, size);
		skin.add_to_buffer(buffer);
		super(skin, new PhysicsVehicle(x, y, size));
		physics.teleport_to(x, y);
		physics.size.radius = size / 3;
		this.init_x = physics.position.x;
		this.init_y = physics.position.y;
		this.path = [];
	}

	public function set_path(path:Array<Basic>) {
		this.path = path;
	}

	public function change_direction_x(direction:Int) {
		physics.start_steer(direction);
	}

	public function stop_x() {
		physics.stop_steer();
	}

	public function change_direction_y(direction:Int) {
		physics.start_thrust();
	}

	public function stop_y() {
		physics.stop_thrust();
	}

	public function hold_trigger() {
		is_trigger_held = true;
		fire(physics.position.r);
	}

	public function release_trigger() {
		is_trigger_held = false;
	}

	function fire(angle_degrees:Float) {
		var missile = projectiles.get_item();
		if (missile != null) {
			missile.revive(this);
			missile.skin.scale(2.0, 2.0);
			missile.physics.teleport_to(physics.position.x, physics.position.y);
			missile.physics.velocity.friction_y = 0;
			missile.skin.change_alpha(1.0);
			missile.skin.change_tint(0xffd677F0);

			var speed = 5.0;
			var radians = angle_degrees * RADIANS;
			missile.physics.velocity.delta_x = Math.sin(radians) * speed;
			missile.physics.velocity.delta_y = -Math.cos(radians) * speed;
		}
	}

	var path_index = 0;

	override function update() {
		state.on_state_update();
		super.update();
		cool_down_count--;
		if (cool_down_count <= 0) {
			cool_down_count = cool_down;
			if (is_trigger_held) {
				fire(physics.position.r);
			}
		}
	}

	public function change_state(next:BoatState) {
		state = states[next];
	}

	public function cache() {
		skin.change_alpha(0.0);
		physics.teleport_to(-100, -100);
	}

	public function reset() {
		physics.stop_steer();
		physics.stop_thrust();
		physics.thrust_delta = 0;
		// physics.acceleration.thrust = 0;
		// physics.acceleration.spin = 0;
		
		physics.position.r_previous = 0;
		physics.position.r = 0;
		physics.velocity.delta_r = 0;
		physics.velocity.delta_x = 0;
		physics.velocity.delta_y = 0;
	}
}

@:structInit
@:publicFields
class BoatModel {
	var size_body:Int;
	var size_grid:Int;
	var color:Color;
}

class BoatCache extends ObjectCache<Boat> {
	var sprites:Buffer<Basic>;
	var template:BoatModel;
	var projectiles:ObjectCache<Projectile>;

	public function new(max_items:Int, sprites:Buffer<Basic>, projectiles:ObjectCache<Projectile>) {
		super(max_items);
		this.sprites = sprites;
		this.projectiles = projectiles;
		template = {
			size_body: 42,
			size_grid: 60,
			color: 0xf0f0f0d0
		}
	}

	public function set_template(template:BoatModel) {
		this.template = template;
	}

	public function create_item():Boat {
		return new Boat(-1, -1, template.size_body, template.size_grid, sprites, projectiles);
	}

	public function on_cache_item(item:Boat) {
		item.cache();
	}
}

@:structInit
@:publicFields
class ProjectileModel {
	var size_body:Int;
	var size_skin:Int;
	var color:Color;
}

class ProjectileCache extends ObjectCache<Projectile> {
	var sprites:Buffer<Basic>;
	var template:ProjectileModel;

	public function new(max_items:Int, sprites:Buffer<Basic>) {
		super(max_items);
		this.sprites = sprites;
		set_template({
			size_body: 6,
			size_skin: 6,
			color: 0xf0f0f0d0
		});
	}

	public function set_template(template:ProjectileModel) {
		this.template = template;
	}

	public function create_item():Projectile {
		var projectile = new Projectile(template.size_body, template.size_skin, (grid_x, grid_y) -> false);
		sprites.addElement(projectile.skin.element);
		return projectile;
	}

	public function on_cache_item(item:Projectile) {
		item.on_cache();
	}
}


enum BoatState {
	IDLE;
	EXPIRED;
}

class BoatDoNothin extends State<SkinBoat, PhysicsVehicle> {
	public function on_state_init() {}

	public function on_state_enter() {}

	public function on_state_update() {}
}
