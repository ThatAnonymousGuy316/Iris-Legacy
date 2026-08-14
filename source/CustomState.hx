package;

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

typedef StateJson = {
    var objects:Array<StateObject>;
    var backgroundTexture:String;
    var backgroundX:Float;
    var backgroundY:Float;
    var backgroundAlpha:Float;
}

typedef StateObject = {
    var name:String;
    var hasFrames:Bool;
    var animationPrefix:String;
    var animationLoops:Bool;
    var animationFramerate:Int;
    var texture:String;
    var x:Float;
    var y:Float;
    var alpha:Float;
    var scale:Float;
}

class CustomState extends MusicBeatState
{
    public var hscript:FunkinHScript;
    public var lua:FunkinLua;
    public var stateName:String;
    public var daJson:StateJson;
    public var stateObjects:FlxTypedGroup<FlxBasic>;
    public var stateVariables:Map<String, FlxBasic> = new Map<String, FlxBasic>();

    public var optionShit:Array<String> = [];

    public static var curSelected:Int = 0;

    var bg:FlxSprite;

    public function new(stateName:String)
    {
        super();
        this.stateName = stateName;
    }

    override function create()
    {
        super.create();

        daJson = Json.parse(Paths.getTextFromFile('states/${stateName}.json'));
        optionShit = [];

        for (i in daJson.objects)
            optionShit.push(i.name);

        if (sys.FileSystem.exists(Paths.modFolders('states/scripts/${stateName}.${FunkinLua.ext}')))
            lua = new FunkinLua(Paths.modFolders('states/scripts/${stateName}.${FunkinLua.ext}'));

        if (sys.FileSystem.exists(Paths.modFolders('states/scripts/${stateName}.${FunkinHScript.ext}')))
            hscript = new FunkinHScript(Paths.modFolders('states/scripts/${stateName}.${FunkinHScript.ext}'));

        setScript('getObject', getObject);

        setScript('getOptions', function() {
            return optionShit[curSelected];
        });

        if (hscript != null)
            hscript.set('optionShit', optionShit);

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
            sprite.scale.x = object.scale;
            sprite.scale.y = object.scale;
            stateObjects.add(sprite);
            stateVariables.set(object.name, sprite);
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        callScript('onUpdate', [elapsed]);

        if (controls.BACK)
            callScript('onBack', []);

		if (controls.UI_UP_P)
		{
            callScript('onUp', []);
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(-1);
            callScript('onUpPost', []);
		}

		if (controls.UI_DOWN_P)
		{
            callScript('onDown', []);
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(1);
            callScript('onDownPost', []);
		} 

        if (controls.ACCEPT)
        {
            callScript('onAcceptPre', []);

            switch (optionShit[curSelected])
            {
                default:
                    if (sys.FileSystem.exists(Paths.modFolders('states/buttons/${optionShit[curSelected]}.${FunkinLua.ext}')))
                        var scriptlua = new FunkinLua(Paths.modFolders('states/buttons/${optionShit[curSelected]}.${FunkinLua.ext}'));

                    if (sys.FileSystem.exists(Paths.modFolders('states/buttons/${optionShit[curSelected]}.${FunkinHScript.ext}')))
                        var scripthscript = new FunkinHScript(Paths.modFolders('states/buttons/${optionShit[curSelected]}.${FunkinHScript.ext}'));

                    callScript('onAccept', []);
            }

            callScript('onAcceptPost', []);
        }
    }

    override public function beatHit()
    {
        super.beatHit();

        setScript('curBeat', curBeat);
        callScript('onBeatHit', []);
    }

    override public function stepHit()
    {
        super.stepHit();

        setScript('curStep', curBeat);
        callScript('onStepHit', []);
    }

    public function callScript(func:String, args:Array<Dynamic>):Void
    {
        if (lua != null)
            lua.call(func, args);

        if (hscript != null)
            hscript.call(func, args);
    }

    public function setScript(name:String, value:Dynamic):Void
    {
        if (lua != null)
            lua.set(name, value);

        if (hscript != null)
            hscript.set(name, value);
    }

    public function changeItem(change:Int = 0)
    {
        curSelected += change;
		if (curSelected >= stateObjects.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = stateObjects.length - 1;
        callScript('onChangeItem', [change]);
    }

    public function getObject(name:String):FlxBasic
    {
        return stateVariables.get(name);
    }
}