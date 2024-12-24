package engine;

import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Level {
	var tile_map:Array<String>;

	public var width_tiles(get, never):Int;
	public var height_tiles(get, never):Int;
	public var width_pixels(get, never):Int;
	public var height_pixels(get, never):Int;
	public var entity_count:Int = 0;

	var tile_size:Int;

	public var entity_positions(default, null):Map<String, Array<Array<Int>>> = [];

	public function new(display:Display, tile_map:Array<String>, tile_size:Int) {
		this.tile_map = tile_map;
		this.tile_size = tile_size;
		var tile_count = tile_map.length * tile_map[0].length;

		var buffer = new Buffer<Basic>(tile_count, true);
		var program = new Program(buffer);
		display.addProgram(program);

		for (y => row in tile_map) {
			for (x in 0...row.length) {
				var key = row.charAt(x);

				if (key == " ") {
					// empty space, nothin to do
					continue;
				}

				if (key == "#") {
					// it's a wall, init a graphic
					var x = x * tile_size;
					var y = y * tile_size;
					var graphic = new Basic(x, y, tile_size);
					// x and y are offset to the center of the graphic by default
					// for level tiles adjust this offset to be top left
					graphic.pivot_x = 0.0;
					graphic.pivot_y = 0.0;
					buffer.addElement(graphic);
					continue;
				}

				// store entity for initialising later
				if (!entity_positions.exists(key)) {
					entity_positions[key] = [];
				}
				entity_positions[key].push([x, y]);
				entity_count++;
			}
		}
	}

	inline function is_out_of_bounds(grid_x:Int, grid_y:Int):Bool {
		return grid_x < 0 || grid_y < 0 || width_tiles <= grid_x || height_tiles <= grid_y;
	}

	public function has_tile_at(grid_x:Int, grid_y:Int):Bool {
		if (is_out_of_bounds(grid_x, grid_y)) {
			return true;
		}

		if (grid_y > tile_map.length || grid_y < 0) {
			return false;
		}

		if (grid_x > tile_map[0].length || grid_x < 0) {
			return false;
		}

		return tile_map[grid_y].charAt(grid_x) == "#";
	}

	function get_width_pixels():Int {
		return tile_map[0].length * tile_size;
	}

	function get_height_pixels():Int {
		return tile_map.length * tile_size;
	}

	function get_width_tiles():Int {
		return tile_map[0].length;
	}

	function get_height_tiles():Int {
		return tile_map.length;
	}
}
