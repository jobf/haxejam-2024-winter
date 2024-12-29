package game.activities;

class Boating {
	var input:Input;
	var lines:Array<Basic> = [];
	var is_ready:Bool;
	var particles:ObjectCache<Projectile>;
	var other_boats:ObjectCache<Boat>;
	var hud:Hud;
	var cursor:Basic;
	var element:Basic;
	var mouse_x:Float = 0;
	var mouse_y:Float = 0;
	var hero:Boat;
	var camera:Camera;
	var terrain:Buffer<Basic>;
	var bg:Basic;
	var elements_empty:Buffer<Basic>;
	var elements_sprite:Buffer<Tile>;
	var level:Course;
	var is_playing:Bool = false;
	var is_elite:Bool = false;
	var is_fishing:Bool = false;
	var is_on_land:Bool = false;
	var fishing:Fishing;
	var is_game_over:Bool = false;
	var is_input_enabled:Bool = false;
	
	public function new(display:Display, hud_display:Display, input:Input, map_json:String) {
		this.input = input;
		
		
		hud = new Hud(hud_display, 32);
		hud.intro.on_ready = () -> start();
		
		// fishing = new Fishing(display, hud_display);

		fishing = new Fishing(hud_display, hud_display);

		var water_png = Assets.getImage("assets/1000-water-249-xtra-bg-2.png");
		var mask_png = Assets.getImage("assets/1000-water-249-mask.png");
		var water_size = 3000;

		var wet = 0x1020f080.color2vec4();
		var dry = 0x1D2A0Aa0.color2vec4();

		terrain = Basic.init_buffer(display, 1, program -> {
			
			program.addTexture(Texture.fromData(water_png));
			program.addTexture(Texture.fromData(mask_png), "mask");

			// !!!! error on web
			/// Name conflicts between a uniform and a uniform block field: uZoom 
			
			program.injectIntoFragmentShader("
			// uniform vec2 uZoom; // this is need if using gl_FragCoord to make a global pattern (but keep into zoom of the Display)

			const float param_A = 0.87, param_B = 0.2223, param_C = -0.1843, param_D = 0.9126, param_E = 1.2;
			const float param_INTERFERENCE = 0.3, param_INTERFERENCE_ZOOM = 10.8, param_INTERFERENCE_SHIFT = 0.14;
			const float param_SPEED = 0.16, param_ASPECT = 0.4, param_ZOOM = 15.0;
			const float param_CONTRAST = 0.25;

			vec2 sin2(vec2 p) {
				return abs(vec2(sin(p.x + sin(p.y)), sin(p.y + sin(p.x))));
			}
			
			
			float sineWaves(vec2 p1)
			{
				vec2 p2 = p1;
				float ret = 0.0;
				mat2 matrix = param_E * mat2(param_A, param_B, param_C, param_D);
				float t = uTime * param_SPEED;
				
				for (int i=0; i<5; i++)
				{
					p1 = (p1 + ( sin2(2.0*p2) * param_INTERFERENCE + t) ) * matrix;
					p2 = p2 * param_INTERFERENCE_ZOOM + param_INTERFERENCE_SHIFT;
					ret += abs( fract( p1.y + abs(fract(p1.x) - 0.5) ) - 0.5);
				}
				
				return param_CONTRAST / ret;
			}

			vec4 water2D( vec4 c )
			{
				float waves = sineWaves( vec2(vTexCoord.x * vSize.x, (vTexCoord.y * vSize.y) / param_ASPECT) / (60.0 * param_ZOOM) );
				// float waves = sineWaves( vec2(gl_FragCoord.x / uZoom.x, (gl_FragCoord.y / uZoom.y) / param_ASPECT) / (60.0 * param_ZOOM) );
				
				waves *= waves;
				return vec4( waves + vec3(c.r, c.g, c.b), c.a);
			}			
				vec4 paint(int texId, int maskId, vec4 water)
				{
					vec4 tex = getTextureColor(texId, vTexCoord);
					vec4 mask = getTextureColor(maskId, vTexCoord);
					return mix(tex, water, mask.a);
				}
			", true);

			program.setColorFormula('paint(default_ID, mask_ID, water2D($wet))');
		});


		var tiles_png = Assets.getImage("assets/200-entity.png");
		var tile_size = 200;
		elements_sprite = Tile.init_buffer(display, 1, tiles_png, tile_size);

		
		elements_empty = Basic.init_buffer(display, 64);

		level = new Course(map_json);

		var c = Std.int(level.start_x / tile_size);
		var r = Std.int(level.start_y / tile_size);

		var size = 40;
		var ctr = size * 0.5;

		var gap = 20;
		var space = size + gap;
		hero = new Boat(0, 0, size, space, elements_empty, particles);
		// hero.physics.position.r += 90;
		// hero.physics.position.r_previous = hero.physics.position.r;
		elements_sprite.addElement(hero.skin.sprite);
		hero.physics.teleport_to(level.start_x, level.start_y);

		hero.update();

		var scrolling:ScrollConfig = {
			view_width: display.width,
			view_height: display.height,

			boundary_right: Std.int(level.width),
			boundary_floor: Std.int(level.height),

			zone_center_x: level.start_x, // Std.int(hero.physics.position.x),
			zone_center_y: level.start_y, // Std.int(hero.physics.position.y),
			zone_width: 20,
			zone_height: 20,
			smoothing: 0.7
		}

		camera = new Camera(display, scrolling);
		// camera.center_on(hero.physics.position.x, hero.physics.position.y);
		// camera.draw(1.0);
		// camera.toggle_debug();

		var projectile_count = 50;
		particles = new ProjectileCache(projectile_count, elements_empty);

		bg = terrain.addElement(new Basic(0, 0, water_size, false));

		other_boats = new BoatCache(50, elements_empty, particles);

		cursor = new Basic(0, 0, 5);
		cursor.tint = 0x4060d000;
		elements_empty.addElement(cursor);

		// set up lines, will collid with these 
		for (model in level.model.lines) {
			var from = level.transform_model_point(model.from);
			var to = level.transform_model_point(model.to);
			var element = new Basic(0, 0, 1);
			element.tint.aF = 0.0;
			element.to_line(from.x, from.y, to.x, to.y, false, 12);
			elements_empty.addElement(element);
			lines.push(element);
			draw_debug(element);
		}
		display.peoteView.window.onMouseMove.add((x, y) -> {
			cursor.x = x;
			cursor.y = y;
			mouse_x = x;
			mouse_y = y;
		});

		input.change_target({
			left: {
				on_press: () -> {
					if (!is_playing || !is_input_enabled)
						return;
					hero.change_direction_x(-1);
					hero.skin.sprite.tile_index = 2;
				},
				on_release: () -> {
					if (!is_playing || !is_input_enabled)
						return;
					hero.stop_x();
					hero.skin.sprite.tile_index = 0;
				}
			},
			right: {
				on_press: () -> {
					if (!is_playing || !is_input_enabled)
						return;
					hero.change_direction_x(1);
					hero.skin.sprite.tile_index = 1;
				},

				on_release: () -> {
					if (!is_playing || !is_input_enabled)
						return;
					hero.stop_x();
					hero.skin.sprite.tile_index = 0;
				}
			},

			
			a: {
				on_press: () -> {
					if(is_fishing){

						handle_rod();
					}
					// explode();
					// hero.hold_trigger();
				},
				// on_release: () -> hero.release_trigger()
			},
			select: {
				on_press: () -> return
			}
		});

		hud.intro.shutter_on();
		is_ready = true;
		is_playing = true;
		// start_fishing();
	}

	function handle_rod() {
		if(is_game_over) return;

		is_game_over = true;
		
		fishing.rod.pull_rod();

		fishing.is_bonus = is_elite;
		
		if(fishing.rod.is_caught)
		{
			hud.help.show_message([
				'What did you catch?',
				''
			], [
				"Press F5 to start again?", ""
			]);

		}
		else{
			hud.help.show_message([
				'You reel the line...',
				'but it got away!'
			], [
				"Press F5 to start again?", ""
			]);
		}
	}

	function draw_debug(line:Basic) {
		elements_empty.addElement(line.filled);
	}

	var distance_threshold:Float = 100;

	public function fixed_step_update() {
		// if(!is_playing) return;
		if (is_playing) {

			if(is_fishing)
			{
				fishing.fixed_step_update();

			}
			else
			{
				// boating
				hero.update();
				update_camera();

				if (!hero.is_on_water) {
					// on land !!!

					if (level.fishing_checkpoint.is_point_inside(hero.physics.position.x, hero.physics.position.y)) {
						start_fishing();
					}

				} else {
					
					if (!is_elite && level.bonus_checkpoint.is_point_inside(hero.physics.position.x, hero.physics.position.y)) {
						// reached bonus, keep boatin'
						start_bonus();
					}

					if (level.person_checkpoint.is_point_inside(hero.physics.position.x, hero.physics.position.y)) {
						// reached person zone, change mode
						start_land();
					}

				}

				if(hero.skin.pointer.x < 0 || hero.skin.pointer.x > level.width)
				{
					crash();
				}
				if(hero.skin.pointer.y < 0 || hero.skin.pointer.y > level.height)
				{
					crash();
				}

				crash_into_lines();

				particles.iterate_active(projectile -> {

					projectile.update();
					return projectile.age >= 300;

				});
			}
		}

		hud.update();
	}

	function update_camera() {
		var target_width_offset = (hero.physics.size.tile_size / 2);
		var target_height_offset = target_width_offset;
		var target_left = hero.physics.position.x - target_width_offset;
		var target_right = hero.physics.position.x + target_width_offset;
		var target_ceiling = hero.physics.position.y - target_height_offset;
		var target_floor = hero.physics.position.y + target_height_offset;

		camera.follow_target(target_left, target_right, target_ceiling, target_floor);
	}

	function crash_into_lines() {
		for (line in lines) {
			if (line.filled.is_inside_area(hero.skin.pointer.x, hero.skin.pointer.y)) {
				// if (true) {
				// line.tint = 0x3050f060;

				#if debug
				line.filled.tint.aF = 0.15;
				#end

				if (hero.collides_with(line)) {
					#if debug
					line.tint = 0xd8142580;
					#end

					hero.overlapping_for++;

					if (hero.overlapping_for > 0) {
						crash();
					}

					break;
				}
			} else {
				#if debug
				// line.tint = 0xf0f0f050;
				line.filled.tint.aF = 0.0;
				#end
			}
		}
	}

	function explode() {
		// for (n in 0...15) {
		// 	var projectile = particles.get_item();
		// 	if (projectile != null) {
		// 		// todo
		// 	}
		// }
	}

	function start()
	{
		// is_on_land = true;
		// hero.physics.teleport_to(level.start_x, level.start_y);
		// camera.center_on(level.start_x, level.start_y);
		// camera.stop();
		is_input_enabled = true;

		#if debug
		for (line in lines) {
			line.tint = 0xf0f0f050;
		}
		#end
		
		hud.intro.shutter_off();
		is_playing = true;

		num_tries++;
		
		if(is_on_land){
			hero.set_person_mode();
		}
		else{
			hero.reset();
			hud.help.person_message_index = 0;
			hero.set_boat_mode();
			hero.physics.teleport_to(level.start_x, level.start_y);
		}

		hero.physics.start_thrust();

		// hud.intro.bg.tint.a = 0;
		// hud.intro.colors.updateElement(bg);
	}

	function crash() {
		trace('crash');
		is_elite = false;
		fishing.is_bonus = false;
		// explode();

		hero.physics.stop_thrust();
		hero.skin.sprite.tint.a = 0;
		is_playing = false;
		disable_input();
		hud.reset();
		hero.stop();
		camera.stop();

		if(is_on_land)
		{
			hud.help.show_person_message(false);
		}else{

			if (num_tries > 0) {
				hud.help.show_boat_message(num_tries > 1);
			}
		}

		is_fishing = false;
		is_on_land  = false;
	}

	function disable_input() {
		is_input_enabled = false;
	}

	function enable_input() {
		is_input_enabled = true;
	}

	function start_land() {
		trace('start_land');
		is_on_land = true;
		hero.physics.stop_thrust();
		// hero.skin.sprite.tint.a = 0;
		is_playing = false;
		disable_input();
		hero.stop();
		hud.reset();
		// camera.stop();

		hud.help.show_person_message(false);
	}

	function start_fishing() {
		trace('start fishin');
		camera.zero();
		hud.intro.shutter_on();
		is_fishing = true;
		fishing.show();

	}

	function start_bonus() {
		is_elite = true;
		trace('elieee');
	}

	var num_tries:Int = 0;


	public function draw(frame_ratio:Float) {
		
		if (is_fishing) {
			fishing.draw(frame_ratio);
		} else {
			particles.iterate_all(projectile -> projectile.draw(frame_ratio));
			hero.draw(frame_ratio);
			camera.draw(frame_ratio);
		}

		hud.draw(frame_ratio);

		elements_empty.update();
		elements_sprite.update();

	}
}
