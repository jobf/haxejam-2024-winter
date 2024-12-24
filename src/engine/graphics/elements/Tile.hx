package engine.graphics.elements;

import peote.view.*;

class Tile implements Element {

	/** Position of the element on x axis. Relative to top left of Display.**/
	@posX public var x:Float;

	/** Position of the element on y axis. Relative to top left of Display.**/
	@posY public var y:Float;

	/** Size of the element on x axis. **/
	@sizeX public var width:Int;

	/** Size of the element on y axis. **/
	@sizeY public var height:Int;

	/** Tint the element with RGBA color. **/
	@color public var tint:Color = 0xffffff40;
	
	/** Index of tile in texture. Tiles are arranged left to right, row by row. **/
	@texTile public var tile_index:Int = 0;

	/** Auto-enable blend in the Program the element is rendered by (for alpha and more) **/
	var OPTIONS = {blend: true};

	/** Degrees of rotation. **/
	@rotation public var angle:Float = 0.0;

	/** The pivot point around with the element will rotate on the x axis - 0.5 is the center. **/
	@pivotX @formula("width * pivot_x") public var pivot_x:Float = 0.5;

	/** The pivot point around with the element will rotate on the y axis - 0.5 is the center. **/
	@pivotY @formula("height * pivot_y") public var pivot_y:Float = 0.5;

	/**
		@param x the starting x position in the Display.
		@param y the starting x position in the Display.
		@param size the starting width and height.
		@param index the starting tile index.
		@param height (optional) the starting height, in case it is different to the width.
	**/
	public function new(x:Float, y:Float, size:Float, index:Int, height:Null<Int>=null) {
		this.x = Std.int(x);
		this.y = Std.int(y);
		width = Std.int(size);
		this.height = height ?? width;
		tile_index = index;
	}

	public static function init_buffer(display:Display, size:Int = 256, texture:TextureData, tile_size:Int, init:Program->Void = null) {
		var buffer = new Buffer<Tile>(size, size);
		var program = new Program(buffer);
		// program.blendEnabled = true;
		var tex = Texture.fromData(texture);
		tex.tilesX = Std.int(tex.width / tile_size);
		tex.tilesY = Std.int(tex.height / tile_size);
		program.setTexture(tex);
		if (init != null) {
			init(program);
		}
		program.addToDisplay(display);
		return buffer;
	}
}
