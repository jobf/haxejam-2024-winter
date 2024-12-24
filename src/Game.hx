import engine.geom.Shapes.is_point_inside_rectangle;
import game.Hud;
import game.Course;
import engine.graphics.elements.Tile;
import lime.utils.Assets;
import engine.geom.Vector2.distance_to_point;
import engine.actor.Projectile;
import engine.ObjectCache;
import engine.Loop;
import engine.Input;
import engine.graphics.elements.Basic;
import peote.view.*;
import game.Boat;
import engine.graphics.Camera;

using engine.geom.Vector2;
using peote.view.intern.Util;

class Game {
	var loop:Loop;
	var lines:Array<Basic> = [];
	var is_ready:Bool;
	var projectiles:ObjectCache<Projectile>;
	var other_boats:ObjectCache<Boat>;
	var hud:Hud;
	var cursor:Basic;
	var element:Basic;
	var mouse_x:Float = 0;
	var mouse_y:Float = 0;
	var puppet:Boat;
	var hero:Boat;
	var camera:Camera;
	var terrain:Buffer<Basic>;
	var bg:Basic;
	var elements_empty:Buffer<Basic>;
	var elements_sprite:Buffer<Tile>;
	var level:Course;
	var input:Input;
	var is_playing:Bool = false;

	public function new(display:Display, hud_display:Display, input:Input) {
		this.input = input;
		var loader = lime.utils.Assets.loadText("assets/level-map.json");
		loader.onComplete(s -> load_json(s, display, hud_display, input));
	}

	function load_json(map_json:String, display:Display, hud_display:Display, input:Input) {
		hud = new Hud(hud_display, 32);
		hud.intro.on_ready = () -> respawn();

		var tiles_png = Assets.getImage("assets/175-entity.png");
		var tile_size = 175;
		elements_sprite = Tile.init_buffer(display, 1, tiles_png, tile_size);

		var water_png = Assets.getImage("assets/3000-water-249.png");
		var water_size = 3000;

var wet = 0x1020f060.color2vec4();
var dry = 0x1D2A0Aa0.color2vec4();

terrain = Basic.init_buffer(display, 1, program -> {
	program.addTexture(Texture.fromData(water_png));
	program.setColorFormula('getTextureColor(default_ID, vTexCoord).a > 0.0 ? $wet : $dry');
});

		elements_empty = Basic.init_buffer(display, 64);

		level = new Course(map_json);

		var c = Std.int(level.start_x / tile_size);
		var r = Std.int(level.start_y / tile_size);

		var size = 40;
		var ctr = size * 0.5;

		var gap = 20;
		var space = size + gap;
		hero = new Boat(0, 0, size, space, elements_empty, projectiles);
		// hero.physics.position.r += 90;
		// hero.physics.position.r_previous = hero.physics.position.r;
		elements_sprite.addElement(hero.skin.sprite);
		hero.physics.teleport_to(level.start_x, level.start_y);

		puppet = hero;

		var scrolling:ScrollConfig = {
			view_width: display.width,
			view_height: display.height,

			boundary_right: Std.int(level.width),
			boundary_floor: Std.int(level.height),

			zone_center_x: Std.int(hero.physics.position.x),
			zone_center_y: Std.int(hero.physics.position.y),
			zone_width: 20,
			zone_height: 20,
			smoothing: 0.7
		}

		camera = new Camera(display, scrolling);
		// camera.toggle_debug();

		var projectile_count = 50;
		projectiles = new ProjectileCache(projectile_count, elements_empty);

		bg = terrain.addElement(new Basic(0, 0, water_size, false));

		other_boats = new BoatCache(50, elements_empty, projectiles);

		cursor = new Basic(0, 0, 5);
		cursor.tint = 0x4060d000;
		elements_empty.addElement(cursor);

		for (model in level.model.lines) {
			var from = level.transform_model_point(model.from);
			var to = level.transform_model_point(model.to);
			var element = new Basic(0, 0, 1);
			// element.tint.aF = 0.0;
			element.to_line(from.x, from.y, to.x, to.y, false, 8);
			elements_empty.addElement(element);
			lines.push(element);
			draw_debug(element);
		}

		// var get_thrust:() -> String = () -> puppet.physics.thrust_delta + "";
		// var get_spin:() -> String = () -> puppet.physics.acceleration.spin + "";
		// // make_label(() -> "x")
		// hud.make_label(() -> "d x: " + puppet.physics.velocity.delta_x);
		// hud.make_label(() -> "d y: " + puppet.physics.velocity.delta_y);
		// hud.make_label(() -> "d r: " + puppet.physics.velocity.delta_r);
		// hud.make_label(() -> "d thrust: " + get_thrust());

		display.peoteView.window.onMouseMove.add((x, y) -> {
			cursor.x = x;
			cursor.y = y;
			mouse_x = x;
			mouse_y = y;
		});

		var fixed_steps_per_second = 25;

		loop = new Loop({
			step: () -> fixed_step_update(),
			end: frame_ratio -> draw(frame_ratio),
		}, fixed_steps_per_second);

		enabled = {
			left: {
				on_press: () -> {
					if (!is_playing)
						return;
					puppet.change_direction_x(-1);
				},
				on_release: () -> {
					if (!is_playing)
						return;
					puppet.stop_x();
				}
			},
			right: {
				on_press: () -> {
					if (!is_playing)
						return;
					puppet.change_direction_x(1);
				},

				on_release: () -> {
					if (!is_playing)
						return;
					puppet.stop_x();
				}
			},
			// up: {
			// 	on_press: () -> {
			// 		puppet.change_direction_y(-1);
			// 	},
			// 	on_release: () -> puppet.stop_y()
			// },
			// down: {
			// 	on_press: () -> {
			// 		puppet.change_direction_y(1);
			// 	},
			// 	on_release: () -> puppet.stop_y()
			// },
			a: {
				on_press: () -> {
					explode();
					// puppet.hold_trigger();
				},
				// on_release: () -> puppet.release_trigger()
			},
			select: {
				on_press: () -> return
			}
		}

		input.change_target(enabled);
		is_ready = true;
	}

	function draw_debug(line:Basic) {
		elements_empty.addElement(line.filled);
	}

	public function frame(elapsed_ms:Int) {
		if (is_ready) {
			loop.frame(elapsed_ms);
		}
	}

	var distance_threshold:Float = 100;

	function fixed_step_update() {
		if (is_playing) {
			hero.update();
			if (level.end_zone.is_point_inside(hero.physics.position.x, hero.physics.position.y)) {
				reach_finish();
			}

			for (line in lines) {
				if (line.filled.is_inside_area(hero.skin.tip.x, hero.skin.tip.y)) {
					// line.tint = 0x3050f060;
					line.filled.tint.aF = 0.15;
					if (hero.skin.pointer.is_intersection(line)
						|| hero.skin.side_left.is_intersection(line)
						|| hero.skin.side_right.is_intersection(line)
						|| hero.skin.side_left_front.is_intersection(line)
						|| hero.skin.side_right_front.is_intersection(line)) {
						line.tint = 0xff0000f0;
						hero.overlapping_for++;

						if (hero.overlapping_for > 0) {
							crash_boat();
						}

						break;
					}
				} else {
					// line.tint = 0xf0f0f050;
					line.filled.tint.aF = 0.0;
				}
			}

			var target_width_offset = (hero.physics.size.tile_size / 2);
			var target_height_offset = target_width_offset;
			var target_left = hero.physics.position.x - target_width_offset;
			var target_right = hero.physics.position.x + target_width_offset;
			var target_ceiling = hero.physics.position.y - target_height_offset;
			var target_floor = hero.physics.position.y + target_height_offset;

			camera.follow_target(target_left, target_right, target_ceiling, target_floor);
		}

		projectiles.iterate_active(projectile -> {
			projectile.update();
			return projectile.age >= 300;
		});

		hud.update();
	}

	// var disabled:Controller = {}
	var enabled:Controller;

	function explode(){
		for (n in 0...15) {
			var projectile = projectiles.get_item();
			if (projectile != null) {
				var speed = (Math.random() * 5) + 15;
				var angle = (Math.random() * 15);// - 30;
				trace(angle);
				// angle = 0;
				projectile.launch(hero, speed, angle + (hero.physics.position.r - (30 * 5)) );
			}
		}
	}

	function crash_boat() {
		explode();	

		hero.physics.stop_thrust();
		hero.skin.sprite.tint.a = 0;
		is_playing = false;
		hud.reset();
	}

	function reach_finish() {
		is_playing = false;
		hero.physics.stop_thrust();
	}

	function respawn() {
		for (line in lines) {
			line.tint = 0xf0f0f050;
		}
		hero.skin.sprite.tint.aF = 0.5;
		// hero.skin.change_alpha(0.5);
		hero.overlapping_for = 0;
		hero.physics.teleport_to(level.start_x, level.start_y);
		hero.reset();
		camera.center_on(hero.physics.position.x, hero.physics.position.y);

		hero.physics.start_thrust();
		is_playing = true;
	}

	function draw(frame_ratio:Float) {
		if (is_playing) {
			camera.draw(frame_ratio);
			projectiles.iterate_all(projectile -> projectile.draw(frame_ratio));
		}

		hero.draw(frame_ratio);

		elements_empty.update();
		elements_sprite.update();
		hud.draw(frame_ratio);
	}
}
