package;

import haxe.Json;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

typedef CharacterSelectJson = {
    var char:String;
}

class SkinSelectState extends MusicBeatState
{
    var menuBG:FlxSprite;
    public var skin:Character = null;
    public static var curSelectedSkin:Int = 0;

    public var skinArray:Array<String> = ['bf'];

    override function create()
    {
        super.create();
        menuBG = new FlxSprite().loadGraphic(Paths.image('charSelect/secretBG'));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		var selectionArrows:FlxSprite = new FlxSprite().loadGraphic(Paths.image('charSelect/arrowsz'));
		selectionArrows.screenCenter();
		selectionArrows.antialiasing = true;
		add(selectionArrows);

        skin = new Character(0, -20, 'bf');
		add(skin);

        changeChar();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (controls.BACK)
        {
            persistentUpdate = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new FreeplayStateNew());
        }
    
		if (controls.UI_LEFT_P)
			changeChar(-1);
		else if (controls.UI_RIGHT_P)
			changeChar(1);
    }

    function changeChar(change:Int = 0)
    {
        curSelectedSkin += change;
        remove(skin);
        skin = new Character(0, -20, skinArray[curSelectedSkin]);
		add(skin);
    }
}