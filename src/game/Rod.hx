package game;

import engine.Calculate.lerp;
import game.Hud.Label;
import peote.view.*;
import engine.graphics.elements.Basic;
import peote.view.text.TextProgram;

using peote.view.intern.Util;

@:publicFields
class Rod {
	var label:Label;
	var text_program:TextProgram;
	var colors:Buffer<Basic>;
	var meter:Basic;
	var width_max:Float;
	var width:Float;
	var width_previous:Float;
	var delta_start:Float = 0.3;
	var delta:Float = 0.3;
	var attempts:Int = 0;
	var hot:Int = 0xf12bb900;
	var cold:Int = 0x375868ff;
	var hot_spot:Basic;
	var is_pulled:Bool = false;
	var is_caught:Bool = false;

	function new(display:Display) {
		text_program = new TextProgram();
		colors = Basic.init_buffer(display, 4);
		var x = display.width * 0.5;
		var y = display.height - 96;
		width_max = display.width * 0.8;
		width = width_max;
		width_previous = width;
		meter = colors.addElement(new Basic(x, y, width_max, 30, cold));
		hot_spot = colors.addElement(new Basic(x, y, 150, 30, hot));
	}

	function hide() {
		
		hot_spot.tint.a = 0;
		colors.updateElement(hot_spot);
		
		meter.tint.a = 0;
		colors.updateElement(meter);

		// label.fgColor.a = 0;
		// text_program.updateAll();
	}

	function show() {
		hot_spot.tint.a = 255;
		colors.updateElement(hot_spot);
		
		meter.tint.a = 255;
		colors.updateElement(meter);
		
		// label.fgColor.a = 255;
		// text_program.updateAll();
	}

	public function update() {
		if (attempts > 0)
			return;

		width_previous = width;
		width -= delta;
		delta += 0.2;
		if (width <= 0) {
			width = width_max;
			delta = delta_start;
		}
	}

	function pull_rod() {
		if (attempts > 0)
			return;

		hot_spot.tint.a = 0;
		colors.updateElement(hot_spot);

		attempts++;
		if (width < 150) {
			// land_fish
			is_caught = true;
			// colors.updateElement(meter);
		}
		else {
			is_caught = false;
		}
	}

	public function draw(frame_ratio:Float) {
		if(attempts > 0) return;
		meter.width = Std.int(lerp(width_previous, width, frame_ratio));
		// hot_spot.width = Std.int(lerp(width_previous, width, frame_ratio));
		colors.updateElement(meter);
	}
}
// abstract class Meter {
// 	var value:Float;
// 	var value_previous:Float;
// 	var element:Basic;
// 	abstract function update():Void;
// 	abstract function draw(t:Float):Void;
// }
