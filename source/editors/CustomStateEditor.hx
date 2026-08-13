package editors;

import haxe.Json;
import Section;
import Song;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import CustomState;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;

class CustomStateEditor extends MusicBeatState
{
    public var daJson:StateJson;

    public var optionShit:Array<String> = [];

    public var stateObjects:FlxTypedGroup<FlxBasic>;
    public var stateVariables:Map<String, FlxBasic> = new Map<String, FlxBasic>();

    var addObjectButton:FlxButton;
    var addObjectInputText:FlxUIInputText;

    var bg:FlxSprite;

    override function create()
    {
        super.create();
        FlxG.mouse.visible = true;
        daJson = {
            objects: [],
            backgroundTexture: "",
            backgroundX: 0,
            backgroundY: 0,
            backgroundAlpha: 1
        };

        optionShit = [];

        for (i in daJson.objects)
            optionShit.push(i.name);

        if (daJson.backgroundTexture != null && daJson.backgroundTexture != '')
        {
            bg = new FlxSprite(daJson.backgroundX, daJson.backgroundY).loadGraphic(Paths.image(daJson.backgroundTexture));
            bg.antialiasing = ClientPrefs.data.globalAntialiasing;
            bg.alpha = daJson.backgroundAlpha;
            bg.updateHitbox();
            add(bg);
        }

        stateObjects = new FlxTypedGroup<FlxBasic>();
        add(stateObjects);

        for (object in daJson.objects)
        {
            var sprite:FlxSprite = new FlxSprite(object.x, object.y);

            if (object.hasFrames)
            {
                sprite.frames = Paths.getSparrowAtlas(object.texture);
                sprite.animation.addByPrefix(
                    object.animationPrefix,
                    object.animationPrefix,
                    object.animationFramerate,
                    object.animationLoops
                );
                sprite.animation.play(object.animationPrefix);
            }
            else
                sprite.loadGraphic(object.texture);

            sprite.alpha = object.alpha;
            sprite.antialiasing = ClientPrefs.data.globalAntialiasing;

            stateObjects.add(sprite);
            stateVariables.set(object.name, sprite);
        }

        addObjectInputText = new FlxUIInputText(
			15,
			30,
			200,
			"",
			8
		);

		addObjectButton = new FlxButton(
			addObjectInputText.x + 210,
			addObjectInputText.y - 3,
			"Add Object",
			function()
			{
				bg.loadGraphic(Paths.image(imageBackgroundInput.text));
				bg.antialiasing = ClientPrefs.data.globalAntialiasing;
			}
		);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		}
    }

    public function createObject(name:String, texture:String, x:Float, y:Float, ?alpha:Float = 1, ?hasFrames:Bool = false, ?animationPrefix:String, ?animationFramerate:Int, ?animationLoops:Bool)
    {
        var sprite:FlxSprite = new FlxSprite(x, y);

        if (hasFrames)
        {
            sprite.frames = Paths.getSparrowAtlas(texture);
            sprite.animation.addByPrefix(
                animationPrefix,
                animationPrefix,
                animationFramerate,
                animationLoops
            );
            sprite.animation.play(animationPrefix);
        }
        else
            sprite.loadGraphic(texture);

        sprite.alpha = alpha;
        sprite.antialiasing = ClientPrefs.data.globalAntialiasing;

        stateObjects.add(sprite);
        stateVariables.set(name, sprite);
    }
    
    public function saveJson(stateName:String)
    {
        var saveFolder:String = Sys.getCwd() + "/game/states";

        if (!FileSystem.exists(saveFolder))
            FileSystem.createDirectory(saveFolder);

        File.saveContent(
            saveFolder + '/${stateName}.json',
            Json.stringify(daJson, null, "\t")
        );
        trace("Saved JSON files to: " + saveFolder);
    }

    public function load(stateName:String)
    {
        daJson = Json.parse(Paths.getTextFromFile('states/${stateName}.json'));
        optionShit = [];
        for (i in daJson.objects)
            optionShit.push(i.name);
        if (daJson.backgroundTexture != null && daJson.backgroundTexture != '')
        {
            bg.loadGraphic(Paths.image(daJson.backgroundTexture));
            bg.x = daJson.backgroundX;
            bg.y = daJson.backgroundY;
            bg.alpha = daJson.backgroundAlpha;
        }
        for (object in daJson.objects)
        {
            var sprite:FlxSprite = new FlxSprite(object.x, object.y);

            if (object.hasFrames)
            {
                sprite.frames = Paths.getSparrowAtlas(object.texture);
                sprite.animation.addByPrefix(
                    object.animationPrefix,
                    object.animationPrefix,
                    object.animationFramerate,
                    object.animationLoops
                );
                sprite.animation.play(object.animationPrefix);
            }
            else
                sprite.loadGraphic(object.texture);

            sprite.alpha = object.alpha;
            sprite.antialiasing = ClientPrefs.data.globalAntialiasing;

            stateObjects.add(sprite);
            stateVariables.set(object.name, sprite);
        }
    }
}