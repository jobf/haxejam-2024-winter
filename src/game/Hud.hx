package game;

import peote.view.Buffer;
import engine.graphics.elements.Basic;
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
	public var help:Help;

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
		help = new Help(display);
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
		help.update();
	}

	public function reset() {
		intro.reset();
		help.reset();
	}

	public function is_shutter_down():Bool {
		return intro.shutter.tint == 0;
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
	public var colors:Buffer<Basic>;
	public var shutter:Basic;

	public function new(display:Display, size:Int) {
		colors = Basic.init_buffer(display, 1);
		shutter = colors.addElement(new Basic(0,0,display.width, display.height, 0x000000ff, false));

		program = new TextProgram();
		display.addProgram(program);
		var half = size * 0.5;
		var x = Std.int((display.width * 0.5) - half);
		var y = Std.int((display.height * 0.5) - half);
		text = new Text(x, y, '$number', {
			// fgColor: fgColor,
			// shutterColor: shutterColor,
			letterWidth: size,
			letterHeight: size,
			// letterSpace: letterSpace,
			// lineSpace: lineSpace,
			// zIndex: zIndex
		});
		program.add(text);
		shutter_on();
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
		shutter_off();
		on_ready();
	}

	public function reset() {
		shutter_on();
		is_finished = false;
		number_remaining = number_duration;
		number = 3;
		text.text = '$number';
		program.update(text);
	}

	public var is_finished:Bool = false;

	public var on_ready:() -> Void;

	public function shutter_on() {
		shutter.tint = 0x000000ff;
		colors.updateElement(shutter);
	}
	public function shutter_off() {
		shutter.tint = 0x00000000;
		colors.updateElement(shutter);
	}
}


class Help {
	var program:TextProgram;
	var number:Int = 3;
	var text:Text;

	var strings:Array<Array<String>> = [
		[
			'Step 1: Do not crash.',
			'Step 2: Get good.'
		],
		[
			'I am sensing a theme...',
			'it involves crashing.'
		],
		[
			'If you keep crashing...',
			'Try being better?'
		],
		[
			'Wow, that was',
			'embarrassing!',
		],
		[ 
			'Are you even trying?'
		],
		[ 
			'There must be a',
			'Better way ???'
		],
		[ 
			'The goal is to ',
			'FINISH the course.',
		],
		[
			'Come on! The course',
			'is not hard...',
		],
		[
			'You crash so much...',
			'You must enjoy it!'
		]
	];

	var strings_person = [
		[
			'Phew, we made it...',
			'Explore the island!'
		],
		[
			'Blub.. I.. bl..',
			'cannot swim!'
		],
	];
	
	var lines:Array<Text>;
	var colors:Buffer<Basic>;
	var bg:Basic;
	var size = 32;
	var display:Display;
	var follow_up_message:Null<Array<String>>;
	var is_message_complete:Bool = false;
	
	public function new(display_:Display) {
		display = new Display(0,0, display_.width,display_.height);
		display_.peoteView.addDisplay(display);
		colors = Basic.init_buffer(display, 1, program -> {
			
			program.injectIntoFragmentShader('
				vec4 gradient(vec4 col){
					return vec4(col.rgb, 1.0 - vTexCoord.y);
				}
			');

			program.setColorFormula('gradient(tint)');
		});

		display.yOffset = -250;
		var help_color = 0x1C185100;
		var help_color = 0xAA009E0f;
		
		bg = colors.addElement(new Basic(0,0,display.width, 32 * 5, help_color, false));
		program = new TextProgram();
		display.addProgram(program);
		lines = [for(n in 0...2){
			var text = new Text(size, (size * 2) + ((size + 3) * n), "", {
				// fgColor: fgColor,
				// bgColor: bgColor,
				letterWidth: size,
				letterHeight: size,
				// letterSpace: letterSpace,
				// lineSpace: lineSpace,
				// zIndex: zIndex
			});
			program.add(text);
			text;
		}];
	}

	var number_duration = 15;
	var number_remaining = 15;
	var frames:Int = 0;
	public function update() {
		frames++;
		if(frames % 3 == 0){
			display.yOffset -= 1;
		}
		
		if(!is_message_complete && display.yOffset < -bg.height){
			trace('message ends ' + display.yOffset );
			is_message_complete = true;
		}
		
		if(is_message_complete && follow_up_message != null){
				var message = follow_up_message;
				reset(); 
				show_message(message);
		}
	}

	public function show_message(message:Array<String>, follow_up_message:Array<String> = null){
		is_message_complete = false;
		this.follow_up_message = follow_up_message;
		display.yOffset = 0;
		for(n => msg in message){
			lines[n].text = msg;
			trace(msg);
			program.update(lines[n]);
		}
		bg.tint.a = 255;
		colors.updateElement(bg);
	}

	public function show_boat_message(is_random:Bool){
		var index = is_random ? Std.int(Math.random() * strings.length) : 0;
		var message = strings[index];
		show_message(message);
	}

	public var person_message_index = 0;
	public function show_person_message(is_random:Bool) {
		var message = strings_person[person_message_index];
		if(person_message_index < 1) {
			person_message_index = 1;
		}
		show_message(message);
	}

	public function reset() {
		follow_up_message = null;
		// display.yOffset = 0;
		bg.tint.a = 255;
		colors.updateElement(bg);
		for (line in lines) {
			line.text = "";
			program.update(line);
		}
	}

}


