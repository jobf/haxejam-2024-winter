package game.activities;

class Fishing {
	public var rod:Rod;
	var label:Label;
	var text_program:TextProgram;
	public var is_bonus:Bool = false;
	public var fished_buffer:Buffer<Tile>;
	public var fished_element:Tile;


	public function new(display:Display, hud_display:Display) {

		rod = new Rod(display);
		var size = 32;
		var x = 32;
		var y = display.height - 64;
		label = new Label(x, y, read_state_message, {
			fgColor: 0xffffff00,
			// bgColor: bgColor,
			letterWidth: size,
			letterHeight: size,
		});

		var center_x = display.width * 0.5;
		var center_y = display.height * 0.5;

		fished_buffer = Tile.init_buffer(display, 1, Assets.getImage("assets/300-end.png"), 300);
		fished_element = new Tile(center_x, center_y, 300, 0, 300);
		fished_element.tint.a = 0;
		fished_buffer.addElement(fished_element);

		text_program = new TextProgram();
		text_program.addToDisplay(display);
		text_program.add(label);

		hide();
	}

	function read_state_message():String {
		if (rod.is_caught) {
			if(is_bonus){
				fished_element.tile_index = 1;
				fished_element.tint.a = 255;
				fished_buffer.updateElement(fished_element);
				return "You catched the haxe";
			}
			else{
				fished_element.tile_index = 0;
				fished_element.tint.a = 255;
				fished_buffer.updateElement(fished_element);
				return "An old boot ?!?!?";
			}
		}
		
		if(rod.attempts > 0){
			return "FAIL!!";
		}

		return "Push enter to pull !!";
	}

	public function fixed_step_update() {
		rod.update();
		label.read();
		text_program.update(label);
	}

	public function draw(frame_ratio:Float) {
		rod.draw(frame_ratio);
	}

	public function hide() {
		trace('hide fishin');
		label.fgColor.a = 0;
		text_program.update(label);

		fished_element.tint.a = 0;
		fished_buffer.updateElement(fished_element);

		rod.hide();
	}

	public function show() {
		trace('show fishin');
		label.fgColor.a = 255;
		text_program.update(label);

		rod.show();
	}
}
