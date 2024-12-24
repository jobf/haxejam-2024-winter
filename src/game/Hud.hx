package game;

import peote.view.Color;
import peote.view.Display;
import peote.view.text.*;

class Hud {
	var program:TextProgram;
	var text:Array<Text>;
	var points:Int = 0;

	var label_x = 16;
	var label_y = 40;
	var letterSize:Int;
	var labels:Array<Label> = [];

	public var intro:Introduction;

	public function new(display:Display, letterSize:Int) {
		this.letterSize = letterSize;

		var options:TextOptions = {
			letterWidth: letterSize,
			letterHeight: letterSize,
		};

		program = new TextProgram(options);
		program.addToDisplay(display);

		var infos = ["", "", "",];

		var x = 0;
		text = [
			for (s in infos) {
				var t = new Text(x, 0, s);
				program.add(t);
				x += (s.length * letterSize) + letterSize;
				t;
			}
		];

		intro = new Introduction(display, 32 * 4);
	}

	public function score(points:Int) {
		this.points += points;
		text[0].text = StringTools.lpad(this.points + '', "0", 9);
		program.update(text[0]);
	}

	public function make_label(read:Void->String):Label {
		var label = new Label(label_x, label_y + (labels.length * (letterSize + 2)), read, {
			fgColor: Color.GREY7,
		});
		labels.push(label);
		program.add(label);
		return label;
	}

	public function update() {
		for (label in labels) {
			label.read();
			program.update(label);
		}
		intro.update();
	}

	public function draw(frame_ratio:Float) {
		program.updateAll();
	}

	public function reset() {
		intro.reset();
	}
}

class Label extends Text {
	var read_value:Void->String;

	public function new(x:Int, y:Int, read_value:Void->String, ?textOptions:TextOptions) {
		this.read_value = read_value;
		super(x, y, read_value(), textOptions);
	}

	public function read() {
		text = read_value();
	}
}

class Introduction {
	var program:TextProgram;
	var number:Int = 3;
	var text:Text;

	public function new(display:Display, size:Int) {
		program = new TextProgram();
		display.addProgram(program);

		var half = size * 0.5;
		var x = Std.int((display.width * 0.5) - half);
		var y = Std.int((display.height * 0.5) - half);
		text = new Text(x, y, '$number', {
			// fgColor: fgColor,
			// bgColor: bgColor,
			letterWidth: size,
			letterHeight: size,
			// letterSpace: letterSpace,
			// lineSpace: lineSpace,
			// zIndex: zIndex
		});
		program.add(text);
	}

	var number_duration = 15;
	var number_remaining = 15;

	public function update() {
		if (is_finished)
			return;

		number_remaining--;
		if (number_remaining < 0) {
			number_remaining = number_duration;
			number--;
			text.text = '$number';
			program.update(text);
			if(number <= 0)
			{
				finish();
			}
		}
	}

	function finish() {
		is_finished = true;
		text.text = ' ';
		program.update(text);
		on_ready();
	}

	public function reset() {
		is_finished = false;
		number_remaining = number_duration;
		number = 3;
		text.text = '$number';
		program.update(text);
	}

	public var is_finished:Bool = false;

	public var on_ready:() -> Void;
}

