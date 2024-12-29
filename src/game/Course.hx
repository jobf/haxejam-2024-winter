package game;

import engine.geom.Shapes.Rectangle;
import game.Models;
import hxmath.math.Vector2;

@:publicFields
class Course
{
	var model:CourseModel;
	var width:Float = 2990;
	var height:Float = 2990;


	// var model_index = 252;
	// var start_x = 400;
	// var start_y = 1700;


// real
	var model_index = 249;
	var start_x = 100;
	var start_y = 950;

	// for debugging land transition
	// var start_x = 268;
	// var start_y = 2008;

	// for debugging land section
	// var start_x = 1822;
	// var start_y = 1530;

	var person_checkpoint:Rectangle;
	var fishing_checkpoint:Rectangle;
	var bonus_checkpoint:Rectangle;

	public function new(json:String){
		
		
		var file = Deserialize.parse_file_contents(json);
		model = file.models[model_index];
		// person_checkpoint = new Rectangle(1682, 1337, 344, 416);
		person_checkpoint = {
			x: 1675,
			y: 1337,
			width: 344,
			height: 416
		}

		fishing_checkpoint = {
			x: 1008,
			y: 2061,
			width: 133,
			height: 214
		}

		bonus_checkpoint = {
			x: 0,
			y: 1055,
			width: 752,
			height: 330
		}
	}

	function transform_model_point(point:Vector2, x:Float = 0, y:Float = 0):Vector2 {
		var transformed_point:Vector2 = {
			x: (point.x * width),
			y: (point.y * height),
		}

		var bounds_width_half = width * 0.5;
		var bounds_height_half = height * 0.5;

		var center_x = bounds_width_half;
		var center_y = bounds_height_half;
		transformed_point.x += center_x + x;
		transformed_point.y += center_y + y;
		// var offset_point:Vector2 = {
		// 	x: transformed_point.x + center_x + x,
		// 	y: transformed_point.y + center_y + y
		// }

		return transformed_point;
	}
}