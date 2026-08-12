package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

import haxe.Json;

typedef NoteSplashMeta = {
	var offsetX:Float;
	var offsetY:Float;
	var frameRate:Int;
	var alpha:Float;
}

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	var splashJson:NoteSplashMeta;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		splashJson = Json.parse(Paths.getTextFromFile('splashes/${skin}.json'));

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		if (FlxG.state == PlayState.instance)
		{
			if ((PlayState.curStage == 'school' || PlayState.curStage == 'schoolEvil') && ClientPrefs.data.shadersWeek6)
			{
				{
					var grayscale = new GrayscaleShader();
					this.shader = grayscale;
				}
			}
		}

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.data.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = splashJson.alpha;

		if(texture == null) {
			texture = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(splashJson.offsetX, splashJson.offsetY);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = splashJson.frameRate;
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash red", 24, false);
			animation.addByPrefix("note2-" + i, "note splash red", 24, false);
			animation.addByPrefix("note0-" + i, "note splash red", 24, false);
			animation.addByPrefix("note3-" + i, "note splash red", 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}