import engine.graphics.programs.Framebuffer;
import engine.Input;
import haxe.CallStack;
import lime.app.Application;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

class Main extends Application {
	var game:Game;
	var peote_view:PeoteView;

	override function onWindowCreate() {
		try {

			peote_view = new PeoteView(window);


		} catch (_) {
			trace(CallStack.toString(CallStack.exceptionStack()), _);
		}
	}

	override function onPreloadComplete() {
		
		var game_display = new Framebuffer(peote_view, window.width, window.height);
		Filters.bloom(game_display, 3);
		
		var display = new Display(0, 0, window.width, window.height, Color.GREY1);
		peote_view.addDisplay(display);
		game_display.render_to(display);

		var hud_display = new Display(0, 0, window.width, window.height);
		peote_view.addDisplay(hud_display);
		
		var input = new Input(window);
		game = new Game(game_display, hud_display, input);

		onUpdate.add(deltaTime -> game.frame(deltaTime));
	}
}
