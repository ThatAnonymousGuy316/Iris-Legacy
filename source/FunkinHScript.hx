package;

import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.ds.IntMap;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

import sys.FileSystem;
import sys.io.File;

import flixel.FlxG;

using StringTools;

class FunkinHScript
{
    public var parser:Parser;
    public var interp:Interp;

    public function new(filePath:String)
    {
        parser = new Parser();
        interp = new Interp();
        presetHaxe();
        presetFlixel();
        presetFunkin();
        presetLegacy();
		parser.allowTypes = true;
        interp.execute(parser.parseString(File.getContent(filePath), filePath));
        call('onScript', []);
    }

    public function presetHaxe()
    {
        set('Std', Std);
        set('Math', Math);
        set('StringTools', StringTools);
        set('Dynamic', Dynamic);
        set('Json', haxe.Json);
        set('StringMap', StringMap);
        set('ObjectMap', ObjectMap);
        set('IntMap', IntMap);
        set('importClass', function(className:String)
        {
            var classRef = Type.resolveClass(className);

            if (classRef != null)
            {
                set(className, classRef);
            }
        });
    }

    public function presetFlixel()
    {
        set('FlxG', flixel.FlxG);
        set('FlxBasic', flixel.FlxBasic);
        set('FlxObject', flixel.FlxObject);
        set('FlxSprite', flixel.FlxSprite);
        set('FlxState', flixel.FlxState);
        set('FlxSubState', flixel.FlxSubState);
        set('FlxSound', flixel.sound.FlxSound);
        set('FlxBar', flixel.ui.FlxBar);
        set('FlxButton', flixel.ui.FlxButton);
        set('FlxStringUtil', flixel.util.FlxStringUtil);
        set('FlxText', flixel.text.FlxText);
        set('FlxGroup', flixel.group.FlxGroup);
        set('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
        set('FlxMath', flixel.math.FlxMath);
        set('FlxRandom', flixel.math.FlxRandom);
        set('FlxAnimation', flixel.animation.FlxAnimation);
        set('FlxAnimationController', flixel.animation.FlxAnimationController);
        set('FlxSlider', flixel.addons.ui.FlxSlider);
        set('FlxSkewedSprite', flixel.addons.effects.FlxSkewedSprite);
        set('FlxBackdrop', flixel.addons.display.FlxBackdrop);
        set('add', FlxG.state.add);
        set('remove', FlxG.state.remove);
        set('insert', FlxG.state.insert);
        set('this', FlxG.state);
        set('FlxColor', FunkinHScriptColor);
    }

    public function presetFunkin()
    {
        set('MusicBeatState', MusicBeatState);
        set('MusicBeatSubstate', MusicBeatSubstate);
        set('Note', Note);
        set('NoteSplash', NoteSplash);
        set('StrumNote', StrumNote);
        set('Alphabet', Alphabet);
        set('AttachedSprite', AttachedSprite);
        set('AttachedText', AttachedText);
        set('BGSprite', BGSprite);
        set('HealthIcon', HealthIcon);
        set('Character', Character);
        set('Paths', Paths);
        set('Rating', Rating);
        set('ClientPrefs', ClientPrefs);
        set('ColorSwap', ColorSwap);
        set('FlxUIDropDownMenuCustom', FlxUIDropDownMenuCustom);
        set('CoolUtil', CoolUtil);
        set('Conductor', Conductor);
        set('DialogueBox', DialogueBoxPsych);
        set('DialogueBoxPsych', DialogueBoxPsych);
    }

    public function presetLegacy()
    {
        set('GrayscaleShader', GrayscaleShader);
        set('CRTShader', CRTShader);
        
        set('TJSON', tjson.TJSON);
		set('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		set('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
    }

    public function set(name:String, arg:Dynamic){interp.variables.set(name, arg);}

    public function call(name:String, ?args:Array<Dynamic>)
    {
        if (!interp.variables.exists(name))
            return null;

        var func:Dynamic = interp.variables.get(name);

        if (!Reflect.isFunction(func))
            return null;

        return Reflect.callMethod(null, func, args);
    }
}