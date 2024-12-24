package engine.graphics.programs;

import peote.view.Program;
using peote.view.intern.Util;


function setup_program(program:Program, grid_size:Float) {
	program.injectIntoFragmentShader("
	
	float grid(vec2 st, float res)
	{
		vec2 grid = fract(st*res);
		return (step(res,grid.x) * step(res,grid.y));
	}

	vec4 draw(){
	  vec2 grid_uv = v_uv.xy * params.x; // scale
		float x = grid(grid_uv, params.y); // resolution
		return vec4(vec3(0.5) * x, 0.0);
	}
	");

	program.setColorFormula();
}

function init_program(program:Program, cell_size:Float, resolution:Float) {
	program.blendEnabled = true;

	program.injectIntoFragmentShader("

	float grid(vec2 st, float res)
	{
		vec2 grid = fract(st * res);
		return step(res, grid.x) * step(res, grid.y);
	}

	vec4 compose(vec4 tint, float scale, float resolution)
	{
		vec2 grid_uv = vTexCoord.xy * scale;
		float x = grid(grid_uv, resolution);
		return vec4(tint.rgb, x * tint.a);
	}

	");

	var scale = cell_size.toFloatString();
	var resolution = resolution.toFloatString();

	program.setColorFormula('compose(tint, $scale, $resolution)');
}