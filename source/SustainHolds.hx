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
    public function new(texture:String, x:Float, y:Float)
    {
        super(x, y);
    }
}