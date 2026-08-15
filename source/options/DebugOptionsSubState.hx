package options;

#if hxdiscord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class DebugOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Debug';
		rpcTitle = 'Debug Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Editor Music',
			"If unchecked, disables the music in the editors",
			'editorMusic',
			'bool');
		addOption(option);

		super();
	}

	override function destroy()
	{
		super.destroy();
	}
}
