package funkin.backend.framerate;

import flixel.FlxG;
import haxe.Timer;
import lime.graphics.opengl.GL;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

#if sys
import sys.io.Process;
#end

class FPSCounter extends Sprite
{
	@:noCompletion private var times:Array<Float>;
	@:noCompletion private var deltaTimeout:Float = 0.0;
	var peak:UInt = 0;

	// Base info
	var fpsText:CounterField;
	var fpsField:CounterField;
	var memoryText:CounterField;
	var memoryPeakText:CounterField;

	public function new(x:Float = 10, y:Float = 10)
	{
		super();
		this.x = x;
		this.y = y;
		
		fpsText = new CounterField(0, 0, 22, 100, "", "_sans", FlxColor.WHITE);
		addChild(fpsText);

		fpsField = new CounterField(-30, 9, 13, 100, "", "_sans", FlxColor.WHITE);
		addChild(fpsField);

		memoryText = new CounterField(0, 25, 14, 300, "", "_sans", FlxColor.WHITE);
		addChild(memoryText);

		memoryPeakText = new CounterField(50, 25, 14, 100, "", "_sans", FlxColor.WHITE);
		addChild(memoryPeakText);

		visible = PreferencesMenu.getPref("fps-counter");
		times = [];
	}

	private override function __enterFrame(deltaTime:Float)
	{
		if(!visible) return;
		
		final now:Float = Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();
		
		if (deltaTimeout < 50) {
			deltaTimeout += deltaTime;
			return;
		}
		
		var framerate:Int = times.length;
		if (framerate > FlxG.updateFramerate)
			framerate = FlxG.updateFramerate;

		fpsText.text = '$framerate';
		fpsField.x = fpsText.getLineMetrics(0).width + 5;
		fpsField.text = "FPS" + " [" + Std.int((1 / framerate) * 1000) + "ms]";

		var mem = System.totalMemory;
		if (mem > peak)
			peak = mem;

		memoryText.text = getSizeLabel(mem);
		memoryPeakText.text = " / " + getSizeLabel(peak);

		if(framerate < 30 || framerate > 360) fpsText.textColor = FlxColor.RED; else fpsText.textColor = FlxColor.WHITE;
	}

	final dataTexts = ["B", "KB", "MB", "GB", "TB", "PB"];

	function getSizeLabel(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		while (size > 1024 && data < dataTexts.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;

		if (data <= 2)
			size = Math.round(size);

		return size + " " + dataTexts[data];
	}
}

// From FNF': Doido Engine!
class CounterField extends TextField
{
	public function new(x:Float = 0, y:Float = 0, size:Int = 14, width:Float = 0, initText:String = "", font:String = "", color:Int = 0xFFFFFF)
	{
		super();

		this.x = x;
		this.y = y;
		this.text = initText;

		if(width != 0)
			this.width = width;

		selectable = false;
		defaultTextFormat = new TextFormat(font, size, color);
	}
}
