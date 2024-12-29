import game.activities.*;
import engine.Loop;
import engine.Input;
import peote.view.*;

using engine.geom.Vector2;
using peote.view.intern.Util;

class Game {
	var loop:Loop;
	var boating:Boating;
	// var fishing:Fishing;
	var is_boating:Bool = true;

	public function new(display:Display, hud_display:Display, input:Input) {
		var loader = lime.utils.Assets.loadText("assets/level-map.json");
		loader.onComplete(s -> load_json(s, display, hud_display, input));
	}

	function load_json(map_json:String, display:Display, hud_display:Display, input:Input) 
	{
		boating = new Boating(display, hud_display, input, map_json);
		// fishing = new Fishing(display, hud_display, input);
		
		var fixed_steps_per_second = 25;
		
		loop = new Loop({
			step: () -> fixed_step_update(),
			end: frame_ratio -> draw(frame_ratio),
		}, fixed_steps_per_second);
	}

	public function frame(elapsed_ms:Int) {
		loop.frame(elapsed_ms);
	}

	function fixed_step_update() {
		boating.fixed_step_update();

		// if(is_boating){
		// 	// boating.fixed_step_update();
		// }
		// else{
		// 	// fishing.fixed_step_update();
		// }
	}

	function draw(frame_ratio:Float) {
		boating.draw(frame_ratio);
		// if(is_boating){
		// }
		// else{
		// 	fishing.draw(frame_ratio);
		// }
	}
}



