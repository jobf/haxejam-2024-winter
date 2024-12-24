package engine.actor;

import game.Boat;
import peote.view.*;
import engine.body.Body;
import engine.body.skin.SkinBasic;
import engine.body.physics.PhysicsInGrid;

class Projectile extends Body<SkinBasic, PhysicsInGrid> {
	var angle:Float = 0;

	public var velocity_x_max:Float = 0.52;
	public var velocity_y_max:Float = 0.52;

	public var is_expired:Bool = false;
	var shooter:Any;
	public var age:Int = 0;

	public function new(body_size:Int, tile_size:Int, has_wall_tile_at:(grid_x:Int, grid_y:Int) -> Bool) {
		var skin = new SkinBasic(-999, -999, body_size);
		var physics = new PhysicsInGrid(-10, -10, tile_size, has_wall_tile_at);
		physics.velocity.gravity = 0;
		physics.velocity.friction_x = 0;
		physics.velocity.friction_y = 0;
		physics.size.edge_bottom = 0.7;
		super(skin, physics);
	}

	function on_collide(side_x:Int, side_y:Int) {
		if (physics.velocity.delta_x < 0 && side_x < 0 && physics.position.grid_cell_ratio_x <= physics.size.edge_left) {
			#if debug
			trace('hit left');
			#end
			expire();
		}

		if (physics.velocity.delta_x > 0 && side_x > 0 && physics.position.grid_cell_ratio_x >= physics.size.edge_right) {
			#if debug
			trace('hit right');
			#end
			expire();
		}

		if (physics.velocity.delta_y < 0 && side_y < 0 && physics.position.grid_cell_ratio_y <= physics.size.edge_top) {
			#if debug
			trace('hit top');
			#end
			expire();
		}

		if (physics.velocity.delta_y > 0 && side_y > 0 && physics.position.grid_cell_ratio_y >= physics.size.edge_bottom) {
			#if debug
			trace('bottom');
			#end
			expire();
		}
	}

	public function revive(shooter:Boat) {
		this.shooter = shooter;
		age = 0;
		is_expired = false;
	}

	public function expire() {
		is_expired = true;
	}

	public function on_cache() {
		is_expired = true;
		var x = -999;
		var y = -999;
		skin.change_alpha(0.0);
		skin.move(x, y);
		// acceleration_x = 0;
		// acceleration_y = 0;
		physics.velocity.delta_x = 0;
		physics.velocity.delta_y = 0;
		physics.teleport_to(x, y);
		physics.update();
	}

	override function update() {
		age++;
		// if(age > 30){
		// 	expire();
		// }
		// physics.velocity.delta_x += acceleration_x;

		if (physics.velocity.delta_x > velocity_x_max) {
			physics.velocity.delta_x = velocity_x_max;
		}
		if (physics.velocity.delta_x < -velocity_x_max) {
			physics.velocity.delta_x = -velocity_x_max;
		}

		// physics.velocity.delta_y += acceleration_y;

		if (physics.velocity.delta_y > 0 && physics.velocity.delta_y > velocity_y_max) {
			physics.velocity.delta_y = velocity_y_max;
		}
		if (physics.velocity.delta_y < 0 && physics.velocity.delta_y < -velocity_y_max) {
			physics.velocity.delta_y = -velocity_y_max;
		}

		physics.position.x_previous = physics.position.x;
		physics.position.y_previous = physics.position.y;

		physics.update();
	}

	override function draw(frame_ratio:Float) {
		angle += 15 * physics.velocity.delta_x;
		if (angle > 360)
			angle -= 360;
		skin.rotate(angle);
		super.draw(frame_ratio);
	}

	public function launch(shooter:Boat, speed:Float, angle_degrees:Float) {
		physics.teleport_to(shooter.skin.pointer.to.x, shooter.skin.pointer.to.y);
		skin.change_alpha(1.0);
		physics.update();
		// skin.scale(2.0, 2.0);
		physics.velocity.friction_y = 0;
		
		velocity_x_max = 999;
		velocity_y_max = 999;
		var radians = angle_degrees * RADIANS;
		physics.velocity.delta_x = Math.sin(radians) * speed;
		physics.velocity.delta_y = -Math.cos(radians) * speed;
	}

}


@:structInit
@:publicFields
class ProjectileModel{
	var size_body:Int;
	var size_skin:Int;
	var color:Color;
}

class ProjectileCache extends ObjectCache<Projectile>
{
	var sprites:Buffer<Basic>;
	var template:ProjectileModel;

	public function new(max_items:Int, sprites:Buffer<Basic>)
	{
		super(max_items);
		this.sprites = sprites;
		set_template({
			size_body: 6,
			size_skin: 6,
			color: 0xf0f0f0d0
		});
	}

	public function set_template(template:ProjectileModel){
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
