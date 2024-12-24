package engine.body.skin;

import peote.view.Buffer;
import peote.view.Color;

class SkinBasic extends Skin {
	var element:Basic;
	var width:Float;
	var height:Float;

	public function new(x:Float, y:Float, size:Float) {
		element = new Basic(x, y, size);
		width = element.width;
		height = element.height;
	}

	public function add_to_buffer(buffer:Buffer<Basic>) {
		buffer.addElement(element);
	}

	public function move(x:Float, y:Float) {
		element.x = x;
		element.y = y;
	}

	public function scale(x:Float, y:Float) {
		element.width = Std.int(x * width);
		element.height = Std.int(x * height);
	}

	public function rotate(angle:Float) {
		element.angle = angle;
	}

	public function change_tint(tint:Color) {
		element.tint = tint;
	}

	public function change_alpha(alpha:Float) {
		element.tint.alphaF = alpha;
	}
}
