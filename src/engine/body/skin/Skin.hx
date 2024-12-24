package engine.body.skin;

import peote.view.Color;

@:publicFields
abstract class Skin {
	abstract function move(x:Float, y:Float):Void;

	abstract function scale(x:Float, y:Float):Void;

	abstract function rotate(angle:Float):Void;

	abstract function change_tint(tint:Color):Void;

	abstract function change_alpha(alpha:Float):Void;
}

