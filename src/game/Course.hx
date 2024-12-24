package game;

import engine.geom.Shapes.Rectangle;
import game.Models;
import hxmath.math.Vector2;

@:publicFields
class Course
{
	var model:CourseModel;
	var width:Float = 3000;
	var height:Float = 3000;


	// var model_index = 252;
	// var start_x = 400;
	// var start_y = 1700;


	var model_index = 249;
	var start_x = 100;
	var start_y = 950;
	var end_zone:Rectangle;
	


	public function new(json:String){
		
		
		var file = Deserialize.parse_file_contents(json);
		model = file.models[model_index];
		// end_zone = new Rectangle(1682, 1337, 344, 416);
		end_zone = {
			x: 1682,
			y: 1337,
			width: 344,
			height: 416
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