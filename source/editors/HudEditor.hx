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
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
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
import PlayState;

class HudEditor extends MusicBeatState
{
	var daJsonHealth:HealthBarJson;
	var daJsonScore:ScoreTxtStringJson;

	public var healthBarBG:AttachedSprite;
	public var scoreBar:AttachedSprite;
	public var healthBar:FlxBar;
	public var scoreTxt:FlxText;

	public var health:Float = 1;

	var editorPanel:FlxSprite;
	var selectedText:FlxText;

	var selected:String = "";
	var selectedObject:FlxObject = null;

	var dragging:Bool = false;
	var dragOffsetX:Float = 0;
	var dragOffsetY:Float = 0;

    var uiVisible:Bool = true;

    var editorUI:FlxTypedGroup<FlxBasic>;

	override function create()
	{
		super.create();

		setupWelcomeMusic();

		FlxG.mouse.visible = true;

		daJsonScore = Json.parse(Paths.getTextFromFile('hud/ScoreText.json'));
		daJsonHealth = Json.parse(Paths.getTextFromFile('hud/HealthBar.json'));

		createHUD();
        editorUI = new FlxTypedGroup<FlxBasic>();
	    add(editorUI);
		createUIStuffs();
	}

	function createHUD()
	{
		healthBarBG = new AttachedSprite(daJsonHealth.texture);

		healthBarBG.x = daJsonHealth.x;
		healthBarBG.y = daJsonHealth.y;

		if (ClientPrefs.data.downScroll)
			healthBarBG.y = daJsonHealth.yDownscroll;

		healthBarBG.scrollFactor.set();

		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;

		healthBarBG.x += daJsonHealth.xPlus;
		healthBarBG.y += daJsonHealth.yPlus;

		add(healthBarBG);

		healthBar = new FlxBar(
			healthBarBG.x + 4,
			healthBarBG.y + 4,
			RIGHT_TO_LEFT,
			Std.int(healthBarBG.width - daJsonHealth.barWidth),
			Std.int(healthBarBG.height - daJsonHealth.barHeight),
			this,
			'health',
			0,
			2
		);

		healthBar.scrollFactor.set();

		add(healthBar);

		scoreBar = new AttachedSprite(daJsonScore.scoreBarTexture);

		scoreBar.x = daJsonScore.scoreBarX;
		scoreBar.y = daJsonScore.scoreBarY;

		if (ClientPrefs.data.downScroll)
			scoreBar.y = daJsonScore.scoreBarYDownscroll;

		scoreBar.x += daJsonScore.scoreBarXPlus;
		scoreBar.y += daJsonScore.scoreBarYPlus;

		scoreBar.scale.set(
			daJsonScore.scoreBarScale,
			daJsonScore.scoreBarScale
		);

		scoreBar.alpha = daJsonScore.scoreBarAlpha;
		scoreBar.visible = daJsonScore.enableScoreBar;

		scoreBar.scrollFactor.set();

		add(scoreBar);

		scoreTxt = new FlxText(
			0,
			0,
			FlxG.width,
			daJsonScore.daText,
			20
		);

		scoreTxt.setFormat(
			Paths.font(daJsonScore.font),
			20,
			FlxColor.WHITE,
			CENTER,
			FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK
		);

		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;

		scoreTxt.x = daJsonScore.x;
		scoreTxt.y = daJsonScore.y;

		if (ClientPrefs.data.downScroll)
			scoreTxt.y = daJsonScore.yDownscroll;

		scoreTxt.x += daJsonScore.xPlus;
		scoreTxt.y += daJsonScore.yPlus;

		add(scoreTxt);
	}

	function createUIStuffs()
	{
		var toggleScoreBar = new FlxButton(
			15,
			30,
			"Toggle SB",
			function()
			{
				scoreBar.visible = !scoreBar.visible;
				daJsonScore.enableScoreBar = scoreBar.visible;
			}
		);

		var saveButton = new FlxButton(
			toggleScoreBar.x + 170,
			toggleScoreBar.y,
			"Save",
			function()
			{
				saveJson();
			}
		);

		var scoreTxtDaText = new FlxUIInputText(
			toggleScoreBar.x,
			saveButton.y + 50,
			200,
			daJsonScore.daText,
			8
		);

		var reloadTxt = new FlxButton(
			scoreTxtDaText.x + 220,
			scoreTxtDaText.y,
			"Reload Text",
			function()
			{
				scoreTxt.text = scoreTxtDaText.text;
				daJsonScore.daText = scoreTxt.text;
			}
		);

		editorUI.add(toggleScoreBar);
		editorUI.add(saveButton);
		editorUI.add(scoreTxtDaText);
		editorUI.add(reloadTxt);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.keys.justPressed.F1)
        {
            uiVisible = !uiVisible;
			editorUI.visible = uiVisible;
        }
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;

			MusicBeatState.switchState(
				new editors.MasterEditorMenu()
			);
		}

		if (FlxG.mouse.justPressedRight)
		{
			var mouseX:Float = FlxG.mouse.x;
			var mouseY:Float = FlxG.mouse.y;

			selectedObject = null;
			selected = "";
			if (scoreTxt.visible &&
				mouseX >= scoreTxt.x &&
				mouseX <= scoreTxt.x + scoreTxt.width &&
				mouseY >= scoreTxt.y &&
				mouseY <= scoreTxt.y + scoreTxt.height)
			{
				selectedObject = scoreTxt;
				selected = "scoreTxt";
			}
			else if (scoreBar.visible &&
				mouseX >= scoreBar.x &&
				mouseX <= scoreBar.x + scoreBar.width &&
				mouseY >= scoreBar.y &&
				mouseY <= scoreBar.y + scoreBar.height)
			{
				selectedObject = scoreBar;
				selected = "scoreBar";
			}
			else if (
				(healthBarBG.visible &&
				mouseX >= healthBarBG.x &&
				mouseX <= healthBarBG.x + healthBarBG.width &&
				mouseY >= healthBarBG.y &&
				mouseY <= healthBarBG.y + healthBarBG.height)
				||
				(healthBar.visible &&
				mouseX >= healthBar.x &&
				mouseX <= healthBar.x + healthBar.width &&
				mouseY >= healthBar.y &&
				mouseY <= healthBar.y + healthBar.height)
			)
			{
				selectedObject = healthBarBG;
				selected = "healthBar";
			}
			if (selectedObject != null)
			{
				dragOffsetX = FlxG.mouse.x - selectedObject.x;
				dragOffsetY = FlxG.mouse.y - selectedObject.y;
			}
		}
		if (FlxG.mouse.justPressed && selectedObject != null)
		{
			dragging = true;

			dragOffsetX = FlxG.mouse.x - selectedObject.x;
			dragOffsetY = FlxG.mouse.y - selectedObject.y;
		}
		if (dragging && FlxG.mouse.pressed && selectedObject != null)
		{
			var newX:Float = FlxG.mouse.x - dragOffsetX;
			var newY:Float = FlxG.mouse.y - dragOffsetY;

			if (selected == "healthBar")
			{
				var deltaX:Float = newX - healthBarBG.x;
				var deltaY:Float = newY - healthBarBG.y;

				healthBarBG.x += deltaX;
				healthBarBG.y += deltaY;

				healthBar.x += deltaX;
				healthBar.y += deltaY;
			}
			else
			{
				selectedObject.x = newX;
				selectedObject.y = newY;
			}
		}
		if (FlxG.mouse.justReleased)
		{
			dragging = false;
		}
	}

	public function saveJson()
	{
		if (ClientPrefs.data.downScroll)
		{
			daJsonHealth.x = healthBarBG.x - daJsonHealth.xPlus;
			daJsonHealth.yDownscroll = healthBarBG.y - daJsonHealth.yPlus;
		}
		else
		{
			daJsonHealth.x = healthBarBG.x - daJsonHealth.xPlus;
			daJsonHealth.y = healthBarBG.y - daJsonHealth.yPlus;
		}

		if (ClientPrefs.data.downScroll)
		{
			daJsonScore.x = scoreTxt.x - daJsonScore.xPlus;
			daJsonScore.yDownscroll = scoreTxt.y - daJsonScore.yPlus;
		}
		else
		{
			daJsonScore.x = scoreTxt.x - daJsonScore.xPlus;
			daJsonScore.y = scoreTxt.y - daJsonScore.yPlus;
		}

		if (ClientPrefs.data.downScroll)
		{
			daJsonScore.scoreBarX = scoreBar.x - daJsonScore.scoreBarXPlus;
			daJsonScore.scoreBarYDownscroll = scoreBar.y - daJsonScore.scoreBarYPlus;
		}
		else
		{
			daJsonScore.scoreBarX = scoreBar.x - daJsonScore.scoreBarXPlus;
			daJsonScore.scoreBarY = scoreBar.y - daJsonScore.scoreBarYPlus;
		}

		var saveFolder:String =
			Sys.getCwd() + "/game/hud";

		if (!FileSystem.exists(saveFolder))
			FileSystem.createDirectory(saveFolder);

		File.saveContent(
			saveFolder + "/HealthBar.json",
			Json.stringify(
				daJsonHealth,
				null,
				"\t"
			)
		);

		File.saveContent(
			saveFolder + "/ScoreText.json",
			Json.stringify(
				daJsonScore,
				null,
				"\t"
			)
		);

		trace("HUD JSON saved!");
	}
}