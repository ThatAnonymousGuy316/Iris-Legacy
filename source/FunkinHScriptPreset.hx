package;

import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.ds.IntMap;

import sys.FileSystem;
import sys.io.File;

import flixel.FlxG;

using StringTools;

class FunkinHScriptPreset
{
    public function new(script:Dynamic)
    {
        presetHaxe(script);
        presetFlixel(script);
        presetFunkin(script);
        presetLegacy(script);
    }

    public function presetHaxe(script:Dynamic)
    {
        script.set('Std', Std);
        script.set('Math', Math);
        script.set('StringTools', StringTools);
        script.set('Dynamic', Dynamic);
        script.set('Json', haxe.Json);
        script.set('StringMap', StringMap);
        script.set('ObjectMap', ObjectMap);
        script.set('IntMap', IntMap);
        script.set('importClass', function(className:String)
        {
            var classRef = Type.resolveClass(className);

            if (classRef != null)
            {
                script.set(className, classRef);
            }
        });
    }

    public function presetFlixel(script:Dynamic)
    {
        script.set('FlxG', flixel.FlxG);
        script.set('FlxBasic', flixel.FlxBasic);
        script.set('FlxObject', flixel.FlxObject);
        script.set('FlxSprite', flixel.FlxSprite);
        script.set('FlxState', flixel.FlxState);
        script.set('FlxSubState', flixel.FlxSubState);
        script.set('FlxSound', flixel.sound.FlxSound);
        script.set('FlxBar', flixel.ui.FlxBar);
        script.set('FlxButton', flixel.ui.FlxButton);
        script.set('FlxStringUtil', flixel.util.FlxStringUtil);
        script.set('FlxText', flixel.text.FlxText);
        script.set('FlxGroup', flixel.group.FlxGroup);
        script.set('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
        script.set('FlxMath', flixel.math.FlxMath);
        script.set('FlxRandom', flixel.math.FlxRandom);
        script.set('FlxAnimation', flixel.animation.FlxAnimation);
        script.set('FlxAnimationController', flixel.animation.FlxAnimationController);
        script.set('FlxSlider', flixel.addons.ui.FlxSlider);
        script.set('FlxSkewedSprite', flixel.addons.effects.FlxSkewedSprite);
        script.set('FlxBackdrop', flixel.addons.display.FlxBackdrop);
        script.set('add', FlxG.state.add);
        script.set('remove', FlxG.state.remove);
        script.set('insert', FlxG.state.insert);
        script.set('this', FlxG.state);
        script.set('FlxColor', FunkinHScriptColor);
    }

    public function presetFunkin(script:Dynamic)
    {
        script.set('MusicBeatState', MusicBeatState);
        script.set('MusicBeatSubstate', MusicBeatSubstate);
        script.set('Note', Note);
        script.set('NoteSplash', NoteSplash);
        script.set('StrumNote', StrumNote);
        script.set('Alphabet', Alphabet);
        script.set('AttachedSprite', AttachedSprite);
        script.set('AttachedText', AttachedText);
        script.set('BGSprite', BGSprite);
        script.set('HealthIcon', HealthIcon);
        script.set('Character', Character);
        script.set('Paths', Paths);
        script.set('Rating', Rating);
        script.set('ClientPrefs', ClientPrefs);
        script.set('ColorSwap', ColorSwap);
        script.set('FlxUIDropDownMenuCustom', FlxUIDropDownMenuCustom);
        script.set('CoolUtil', CoolUtil);
        script.set('Conductor', Conductor);
        script.set('DialogueBox', DialogueBox);
        script.set('DialogueBoxPsych', DialogueBoxPsych);
        script.set('Option', options.Option);
    }

    public function presetLegacy(script:Dynamic)
    {
        script.set('goToStoryMode', function(){
            MusicBeatState.switchState(new StoryMenuState());
        });
        script.set('goToFreeplay', function(){
            MusicBeatState.switchState(new FreeplayStateNew());
        });
        script.set('goToFreeplayLegacy', function(){
            MusicBeatState.switchState(new FreeplayState());
        });
        script.set('goToCredits', function(){
            MusicBeatState.switchState(new CreditsState());
        });
        script.set('goToOptions', function(){
            LoadingState.loadAndSwitchState(new options.OptionsState());
        });
        script.set('goToMainMenu', function(){
            MusicBeatState.switchState(new MainMenuState());
        });
        script.set('goToState', function(state:String){
            MusicBeatState.switchState(new CustomState(state));
        });
        script.set('GrayscaleShader', GrayscaleShader);
        script.set('CRTShader', CRTShader);
        script.set('TJSON', tjson.TJSON);
		script.set('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		script.set('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		script.set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
    }
}