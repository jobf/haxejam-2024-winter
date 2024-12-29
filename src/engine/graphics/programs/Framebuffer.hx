package engine.graphics.programs;

import engine.graphics.elements.Basic;
import peote.view.*;

class Framebuffer extends Display {
	var buffer(default, null):Buffer<Basic>;
	var program:Program;
	var frame:Basic;

	public function new(peote_view:PeoteView, width:Int, height:Int, color:Color = 0x000000ff) {
		super(0, 0, width, height, color);
		peote_view.addFramebufferDisplay(this);
		setFramebuffer(new Texture(width, height));
		buffer = new Buffer<Basic>(1);
		program = new Program(buffer);
		program.addTexture(fbTexture);
		frame = new Basic(0, 0, width, height);
		frame.pivot_x = 0;
		frame.pivot_y = 0;
		buffer.addElement(frame);
	}

	public function inject_glsl_program(glsl:String, color_formula:String) {
		program.injectIntoFragmentShader(glsl);
		program.setColorFormula(color_formula);
	}

	public function render_to(display:Display) {
		program.addToDisplay(display);
	}

	public function rotate(angle:Float) {
		frame.angle = angle;
		buffer.updateElement(frame);
	}
}

@:publicFields
class Filters {
	
	static function bloom(fb:Framebuffer, size:Int) {
		fb.inject_glsl_program('
				float normpdf(in float x, in float sigma) { return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma; }
				
				vec4 blur( int textureID )
				{
					const int mSize = $size;
					
					const int kSize = (mSize-1)/2;
					float kernel[mSize];
					float sigma = 7.0;
					
					float Z = 0.0;
					
					for (int j = 0; j <= kSize; ++j) kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
					for (int j = 0; j <  mSize; ++j) Z += kernel[j];
					
					vec3 final_colour = vec3(0.0);
					
					// fix if kernel-offset is over the border
					vec2 texRes = getTextureResolution(textureID);
					vec2 texResSize = texRes + vec2(float(kSize+kSize),float(kSize+kSize));
					
					for (int i = 0; i <= kSize+kSize; ++i)
					{
						for (int j = 0; j <= kSize+kSize; ++j)
						{
							final_colour += kernel[j] * kernel[i] *
								getTextureColor( textureID, (vTexCoord*texRes + vec2(float(i),float(j))) / texResSize ).rgb;
						}
					}
					
					return vec4(final_colour / (Z * Z), 1.0);
				}

				vec4 bloom( int textureID )
				{
					vec4 texColor = getTextureColor(textureID, vTexCoord );
					vec4 bloomColor = blur(textureID);

					// check whether fragment output is higher than threshold, if so add the bloom
					float brightness = dot(bloomColor.rgb, vec3(0.2126, 0.7152, 0.0722));
					if(brightness > 0.01)
					{
						texColor  += bloomColor;
					}

					return texColor;
				}
			'

			, 
			'bloom(default_ID)');
	}
}
