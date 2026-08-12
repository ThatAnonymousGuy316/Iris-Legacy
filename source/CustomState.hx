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
    var attachedScript:String;
    var name:String;
    var hasFrames:Bool;
    var animationPrefix:String;
    var animationLoops:Bool;
    var animationFramerate:Int;
    var texture:String;
    var x:Float;
    var y:Float;
    var alpha:Float;
}

class CustomState extends MusicBeatState
{
    public var stateName:String;
    public var daJson:StateJson;
    public var stateObjects:FlxTypedGroup<FlxBasic>;
    public var stateVariables:Map<String, FlxBasic> = new Map<String, FlxBasic>();
    public function new(stateName:String)
    {
        super();
        this.stateName = stateName;
    }
    override function create()
    {
        daJson = Json.parse(Paths.getTextFromFile('states/${stateName}.json'));
        for (object in daJson.objects)
        {
            var sprite:FlxSprite = new FlxSprite(object.x, object.y);
            if (object.hasFrames)
            {
                sprite.frames = Paths.getSparrowAtlas(object.texture);
                sprite.animation.addByPrefix(object.animationPrefix, object.animationPrefix, object.animationFramerate, object.animationLoops);
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
    
    public function getObject(name:String):FlxBasic
    {
        return stateVariables.get(name);
    }
}