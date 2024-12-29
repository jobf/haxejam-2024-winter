package engine;

import lime.ui.Gamepad;
import input2action.*;
import lime.ui.KeyCode;
import lime.ui.GamepadButton;
import lime.ui.Window;

@:structInit
@:publicFields
class Controller {
	var left:Action = {};
	var right:Action = {};
	var up:Action = {};
	var down:Action = {};
	var a:Action = {};
	var b:Action = {};
	var start:Action = {};
	var select:Action = {};
}

@:structInit
class Action {
	public var on_press:Void->Void = () -> return;
	public var on_release:Void->Void = () -> return;
}

class Input {
	var actionConfig:ActionConfig;
	var actionMap:ActionMap;
	var target:Controller = {};
	var directions:Map<String, Button>;
	var input2Action:Input2Action;
	var keyboard_action:KeyboardAction;

	public function new(window:Window) {
		actionConfig = [
			{
				gamepad: GamepadButton.DPAD_LEFT,
				keyboard: [KeyCode.LEFT, KeyCode.A],
				action: "left"
			},
			{
				gamepad: GamepadButton.DPAD_RIGHT,
				keyboard: [KeyCode.RIGHT, KeyCode.D],
				action: "right"
			},
			{
				gamepad: GamepadButton.DPAD_UP,
				keyboard: [KeyCode.UP, KeyCode.W],
				action: "up"
			},
			{
				gamepad: GamepadButton.DPAD_DOWN,
				keyboard: [KeyCode.DOWN, KeyCode.S],
				action: "down"
			},
			{
				gamepad: GamepadButton.B,
				keyboard: KeyCode.O,
				action: "b"
			},
			{
				gamepad: GamepadButton.A,
				keyboard: [KeyCode.RETURN, KeyCode.NUMPAD_ENTER],
				action: "a"
			},
			{
				gamepad: GamepadButton.BACK,
				keyboard: KeyCode.BACKSPACE,
				action: "back"
			},
			// {
			// 	gamepad: GamepadButton.START,
			// 	keyboard: KeyCode.RETURN,
			// 	action: "start"
			// },
			{
				keyboard: KeyCode.PERIOD,
				action: "edit."
			},
			{
				keyboard: KeyCode.MINUS,
				action: "edit-"
			},
			{
				keyboard: KeyCode.PLUS,
				action: "edit+"
			},
			{
				keyboard: KeyCode.NUMBER_0,
				action: "num0"
			},
			{
				keyboard: KeyCode.NUMBER_1,
				action: "num1"
			},
			{
				keyboard: KeyCode.NUMBER_2,
				action: "num2"
			},
			{
				keyboard: KeyCode.NUMBER_3,
				action: "num3"
			},
			{
				keyboard: KeyCode.NUMBER_4,
				action: "num4"
			},
			{
				keyboard: KeyCode.NUMBER_5,
				action: "num5"
			},
			{
				keyboard: KeyCode.NUMBER_6,
				action: "num6"
			},
			{
				keyboard: KeyCode.NUMBER_7,
				action: "num7"
			},
			{
				keyboard: KeyCode.NUMBER_8,
				action: "num8"
			},
			{
				keyboard: KeyCode.NUMBER_9,
				action: "num9"
			}
		];

		directions = [];
		
		actionMap = [
			"left" => {
				action: (isDown, player) -> {
					group_press(directions, isDown, "left");
				},
				up: true
			},
			"right" => {
				action: (isDown, player) -> {
					group_press(directions, isDown, "right");
				},
				up: true
			},
			"up" => {
				action: (isDown, player) -> {
					group_press(directions, isDown, "up");
				},
				up: true
			},
			"down" => {
				action: (isDown, player) -> {
					group_press(directions, isDown, "down");
				},
				up: true
			},
			"b" => {
				action: (isDown, player) -> {
					if (isDown) {
						target.b.on_press();
					} else {
						target.b.on_release();
					}
				},
				up: true
			},
			"a" => {
				action: (isDown, player) -> {
					if (isDown) {
						target.a.on_press();
					} else {
						target.a.on_release();
					}
				},
				up: true
			},
			"back" => {
				action: (isDown, player) -> {
					if (isDown) {
						target.select.on_press();
					} else {
						target.select.on_release();
					}
				},
				up: true
			},
			"start" => {
				action: (isDown, player) -> {
					if (isDown) {
						target.start.on_press();
					} else {
						target.start.on_release();
					}
				},
				up: true
			},
		];

		input2Action = new Input2Action();
		keyboard_action = new KeyboardAction(actionConfig, actionMap);
		

		Gamepad.onConnect.add(gamepad -> {
			var gamepad_action = new GamepadAction(gamepad.id, actionConfig, actionMap);
			input2Action.addGamepad(gamepad, gamepad_action);
			gamepad.onDisconnect.add(() -> input2Action.removeGamepad(gamepad));
		});

		input2Action.registerKeyboardEvents(window);
		
		input2Action.addKeyboard(keyboard_action);
	}

	public function change_target(target:Controller) {
		this.target = target;
		directions = [
			"left" => {
				on_press: target.left.on_press,
				on_release: target.left.on_release,
			},
			"right" => {
				on_press: target.right.on_press,
				on_release: target.right.on_release,
			},
			"up" => {
				on_press: target.up.on_press,
				on_release: target.up.on_release,
			},
			"down" => {
				on_press: target.down.on_press,
				on_release: target.down.on_release,
			},
		];
	}

	public function enable(){
		input2Action.addKeyboard(keyboard_action);
	}

	public function disable(){
		input2Action.removeKeyboard(keyboard_action);
	}

	var history:Array<Button> = [];

	function group_press(group:Map<String, Button>, is_down:Bool, key:String) {
		if (group.exists(key)) {
			var button = group[key];

			if(is_down){
				button.is_down = true;
				button.on_press();
				history.push(button);
			}
			else{
				button.is_down = false;
				button.on_release();
				history.remove(button);
				
				if(history.length > 0){
					var previous = history[history.length - 1];
					if(previous.is_down){
						previous.on_press();
					}
				}
			}
		}
	}
}

@:structInit
class ButtonPair {
	var on_press_a:() -> Void = () -> return;
	var on_release_a:() -> Void = () -> return;
	var is_pressed_a:Bool = false;

	var on_press_b:() -> Void = () -> return;
	var on_release_b:() -> Void = () -> return;
	var is_pressed_b:Bool = false;

	public function controlA(is_button_pressed:Bool) {
		if (is_button_pressed) {
			is_pressed_a = true;
			on_press_a();
		} else {
			is_pressed_a = false;
			if (is_pressed_b) {
				on_press_b();
			} else {
				on_release_a();
			}
		}
	}

	public function controlB(is_button_pressed:Bool) {
		if (is_button_pressed) {
			is_pressed_b = true;
			on_press_b();
		} else {
			is_pressed_b = false;
			if (is_pressed_a) {
				on_press_a();
			} else {
				on_release_b();
			}
		}
	}
}

@:structInit
@:publicFields
class Button {
	var on_press:() -> Void = () -> return;
	var on_release:() -> Void = () -> return;
	var is_down:Bool = false;
}

@:structInit
class ButtonGroup {
	var on_press_a:() -> Void = () -> return;
	var on_release_a:() -> Void = () -> return;
	var is_pressed_a:Bool = false;

	var on_press_b:() -> Void = () -> return;
	var on_release_b:() -> Void = () -> return;
	var is_pressed_b:Bool = false;

	public function controlA(is_button_pressed:Bool) {
		if (is_button_pressed) {
			is_pressed_a = true;
			on_press_a();
		} else {
			is_pressed_a = false;
			if (is_pressed_b) {
				on_press_b();
			} else {
				on_release_a();
			}
		}
	}

	public function controlB(is_button_pressed:Bool) {
		if (is_button_pressed) {
			is_pressed_b = true;
			on_press_b();
		} else {
			is_pressed_b = false;
			if (is_pressed_a) {
				on_press_a();
			} else {
				on_release_b();
			}
		}
	}
}
