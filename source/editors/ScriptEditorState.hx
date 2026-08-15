package editors;

#if desktop
import Discord.DiscordClient;
#end

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxObject;
import haxe.Json;
import flixel.group.FlxSpriteGroup;

using StringTools;

#if MODS_ALLOWED
import sys.FileSystem;
#end

class ScriptBlock extends FlxSpriteGroup
{
	var dragX:Float = 0;
	var dragY:Float = 0;
	var dragging:Bool = false;

	var textEpic:FlxText;

	public function new(text:String, x:Float, y:Float)
	{
		super(x, y);

		var block = new FlxSprite();
		block.loadGraphic(Paths.image('ScriptEditor/Block'));
		add(block);

		textEpic = new FlxText(0, 0, block.width, text, 12);
		textEpic.setFormat(
			Paths.font("vcr.ttf"),
			16,
			FlxColor.WHITE,
			CENTER,
			FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK
		);

		textEpic.borderSize = 1.25;
		add(textEpic);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed)
		{
			dragging = true;

			dragX = FlxG.mouse.x - x;
			dragY = FlxG.mouse.y - y;
		}

		if (dragging)
		{
			x = FlxG.mouse.x - dragX;
			y = FlxG.mouse.y - dragY;

			if (!FlxG.mouse.pressed)
				dragging = false;
		}
	}
}

class ScriptEditorState extends MusicBeatState
{
    var bg:FlxSprite;
	var camFollow:FlxObject;

	var createBlock:FlxButton;

    override public function create()
    {
		setupWelcomeMusic();
        super.create();
        FlxG.mouse.visible = true;
		bg = new FlxSprite(-80, 0);
		bg.loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.globalAntialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		createBlock = new FlxButton(
			0,
			0,
			"Create Block",
			function()
			{
				add(new ScriptBlock('test', 0, 0).screenCenter());
			}
		);
		add(createBlock);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		}
		if (FlxG.keys.justPressed.R) {
			FlxG.camera.zoom = 1;
		}

		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3) {
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if(FlxG.camera.zoom > 3) FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) {
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
		}
		if (FlxG.keys.pressed.W || FlxG.keys.pressed.A || FlxG.keys.pressed.S || FlxG.keys.pressed.D)
		{
			var addToCam:Float = 500 * elapsed;
			if (FlxG.keys.pressed.SHIFT)
				addToCam *= 4;

			if (FlxG.keys.pressed.W)
				camFollow.y -= addToCam;
			else if (FlxG.keys.pressed.S)
				camFollow.y += addToCam;

			if (FlxG.keys.pressed.A)
				camFollow.x -= addToCam;
			else if (FlxG.keys.pressed.D)
				camFollow.x += addToCam;
		}
    }
}