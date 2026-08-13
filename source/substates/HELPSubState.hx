package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class HELPSubState extends MusicBeatSubstate
{
	// The static variable that other editors will overwrite
	public static var helpText:String = "Default Help Text";

	public function new()
	{
		super();

		// Dark translucent background
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.7;
		bg.scrollFactor.set();
		add(bg);

		// The main help text
		var infoText:FlxText = new FlxText(0, 0, FlxG.width - 100, helpText, 32);
		infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.scrollFactor.set();
		infoText.screenCenter();
		add(infoText);

		// Close prompt at the bottom
		var closePrompt:FlxText = new FlxText(0, FlxG.height - 40, FlxG.width, "Press ESCAPE to close", 20);
		closePrompt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.GRAY, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		closePrompt.scrollFactor.set();
		add(closePrompt);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Close the substate
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			close();
		}
	}
}