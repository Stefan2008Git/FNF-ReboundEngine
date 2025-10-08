package funkin.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"HEY! You're running an outdated version of Rebound Engine!\nCurrent version is v" + MainMenuState.engineVersion
			+ " while the most recent version is 0.2.8!"
			+ "!\nPress Space to Update Engine, or ESCAPE to ignore this!!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);

		#if android
		addVirtualPad(NONE, A_B);
		#end

	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.openURL("https://github.com/Stefan2008Git/FNF-ReboundEngine/releases");
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(() -> new MainMenuState());
		}
		super.update(elapsed);
	}
}
