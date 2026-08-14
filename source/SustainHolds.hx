package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

import haxe.Json;

typedef SustainHoldJson = {
    var offsetX:Float;
	var offsetY:Float;
	var frameRate:Int;
	var alpha:Float;
	var colors:Bool;
}

class SustainHolds extends FlxSprite
{
    public var colorSwap:ColorSwap = null;

    public function new(texture:String, x:Float, y:Float, ?note:Note, noteData:Int = 0)
    {
        super(x, y);

        colorSwap = new ColorSwap();
    }

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
        animation.addByPrefix("start", "holdCoverStart", 24, false);
		animation.addByPrefix("hold", "holdCover0", 24, true);
        animation.addByPrefix("end", "holdCoverEnd", 24, false);
	}
}