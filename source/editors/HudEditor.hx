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

	var textureInput:FlxUIInputText;
	var fontInput:FlxUIInputText;
	var textInput:FlxUIInputText;
	var scaleInput:FlxUIInputText;
	var alphaInput:FlxUIInputText;

    var uiVisible:Bool = true;

    var editorUI:FlxTypedGroup<FlxBasic>;

	override function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		daJsonScore = Json.parse(Paths.getTextFromFile('hud/ScoreText.json'));
		daJsonHealth = Json.parse(Paths.getTextFromFile('hud/HealthBar.json'));

		createHUD();
        editorUI = new FlxTypedGroup<FlxBasic>();
	    add(editorUI);
		createEditorUI();

		selectObject("health");
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

	function createEditorUI()
	{
		editorPanel = new FlxSprite(0, 0);
		editorPanel.makeGraphic(
			300,
			FlxG.height,
			FlxColor.fromRGB(25, 25, 25)
		);

		editorPanel.scrollFactor.set();

		var title = new FlxText(
			15,
			15,
			270,
			"HUD EDITOR",
			24
		);

		title.color = FlxColor.WHITE;
		selectedText = new FlxText(
			15,
			55,
			270,
			"Selected: None",
			16
		);

		selectedText.color = FlxColor.WHITE;

		var healthButton = new FlxButton(
			15,
			90,
			"Health Bar",
			function()
			{
				selectObject("health");
			}
		);

		healthButton.width = 270;
		healthButton.height = 35;

		var scoreBarButton = new FlxButton(
			15,
			135,
			"Score Bar",
			function()
			{
				selectObject("scoreBar");
			}
		);

		scoreBarButton.width = 270;
		scoreBarButton.height = 35;

		var scoreTextButton = new FlxButton(
			15,
			180,
			"Score Text",
			function()
			{
				selectObject("scoreText");
			}
		);

		scoreTextButton.width = 270;
		scoreTextButton.height = 35;

		textureInput = createInput(
			"Texture",
			15,
			245
		);

		fontInput = createInput(
			"Font",
			15,
			305
		);

		textInput = createInput(
			"daText",
			15,
			365
		);

		scaleInput = createInput(
			"Scale",
			15,
			425
		);

		alphaInput = createInput(
			"Alpha",
			15,
			485
		);

		var saveButton = new FlxButton(
			15,
			550,
			"SAVE",
			function()
			{
				saveJson();
			}
		);

		saveButton.width = 270;
		saveButton.height = 40;

        editorUI.add(editorPanel);
        editorUI.add(title);
        editorUI.add(selectedText);
        editorUI.add(healthButton);
        editorUI.add(scoreBarButton);
        editorUI.add(scoreTextButton);
        editorUI.add(saveButton);
	}

	function createInput(
		label:String,
		x:Float,
		y:Float
	):FlxUIInputText
	{
		var labelText = new FlxText(
			x,
			y - 20,
			270,
			label,
			14
		);

		labelText.color = FlxColor.GRAY;

		add(labelText);

		var input = new FlxUIInputText(
			x,
			y,
			270,
			"",
			14
		);

		input.callback = function(
			action:String,
			value:String
		)
		{
			updateProperties();
		};

		add(input);

		return input;
	}

	function selectObject(object:String)
	{
		selected = object;

		switch (object)
		{
			case "health":
				selectedObject = healthBarBG;

				textureInput.text = daJsonHealth.texture;

				fontInput.text = "";
				textInput.text = "";
				scaleInput.text = "";
				alphaInput.text = "";

			case "scoreBar":
				selectedObject = scoreBar;

				textureInput.text = daJsonScore.scoreBarTexture;

				fontInput.text = "";
				textInput.text = "";

				scaleInput.text =
					Std.string(daJsonScore.scoreBarScale);

				alphaInput.text =
					Std.string(daJsonScore.scoreBarAlpha);

			case "scoreText":
				selectedObject = scoreTxt;

				textureInput.text = "";

				fontInput.text = daJsonScore.font;
				textInput.text = daJsonScore.daText;

				scaleInput.text =
					Std.string(scoreTxt.scale.x);

				alphaInput.text = "";
		}

		selectedText.text = "Selected: " + object;
	}

    function updateProperties()
    {
        if (selectedObject == null)
            return;

        switch (selected)
        {
            case "health":
                if (textureInput.text != daJsonHealth.texture)
                {
                    daJsonHealth.texture = textureInput.text;

                    healthBarBG.loadGraphic(
                        Paths.image(daJsonHealth.texture)
                    );

                    healthBar.x = healthBarBG.x + 4;
                    healthBar.y = healthBarBG.y + 4;
                }

            case "scoreBar":
                if (textureInput.text != daJsonScore.scoreBarTexture)
                {
                    daJsonScore.scoreBarTexture = textureInput.text;

                    scoreBar.loadGraphic(
                        Paths.image(daJsonScore.scoreBarTexture)
                    );
                }

                var scale:Float = Std.parseFloat(scaleInput.text);

                if (!Math.isNaN(scale))
                {
                    daJsonScore.scoreBarScale = scale;

                    scoreBar.scale.set(
                        scale,
                        scale
                    );
                }

                var alpha:Float = Std.parseFloat(alphaInput.text);

                if (!Math.isNaN(alpha))
                {
                    daJsonScore.scoreBarAlpha = alpha;
                    scoreBar.alpha = alpha;
                }

            case "scoreText":
                if (fontInput.text != daJsonScore.font)
                {
                    daJsonScore.font = fontInput.text;

                    scoreTxt.setFormat(
                        Paths.font(daJsonScore.font),
                        20,
                        FlxColor.WHITE,
                        CENTER,
                        FlxTextBorderStyle.OUTLINE,
                        FlxColor.BLACK
                    );

                    scoreTxt.borderSize = 1.25;
                }

                daJsonScore.daText = textInput.text;
                scoreTxt.text = daJsonScore.daText;

                var textScale:Float = Std.parseFloat(scaleInput.text);

                if (!Math.isNaN(textScale))
                {
                    scoreTxt.scale.set(
                        textScale,
                        textScale
                    );
                }
        }
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.keys.justPressed.F1)
        {
            uiVisible = !uiVisible;
            editorUI.visible = uiVisible;
        }

		if (selectedObject != null)
		{
			if (
				FlxG.mouse.justPressed &&
				FlxG.mouse.overlaps(selectedObject)
			)
			{
				dragging = true;

				dragOffsetX =
					FlxG.mouse.x - selectedObject.x;

				dragOffsetY =
					FlxG.mouse.y - selectedObject.y;
			}

			if (dragging)
			{
				if (FlxG.mouse.pressed)
				{
					selectedObject.x =
						FlxG.mouse.x - dragOffsetX;

					selectedObject.y =
						FlxG.mouse.y - dragOffsetY;

					updatePosition();
				}
				else
				{
					dragging = false;
				}
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;

			MusicBeatState.switchState(
				new editors.MasterEditorMenu()
			);
		}
	}

	function updatePosition()
	{
		switch (selected)
		{
			case "health":
				daJsonHealth.x =
					healthBarBG.x -
					daJsonHealth.xPlus;

				daJsonHealth.y =
					healthBarBG.y -
					daJsonHealth.yPlus;

				if (ClientPrefs.data.downScroll)
				{
					daJsonHealth.yDownscroll =
						healthBarBG.y -
						daJsonHealth.yPlus;
				}

				healthBar.x =
					healthBarBG.x + 4;

				healthBar.y =
					healthBarBG.y + 4;

			case "scoreBar":
				daJsonScore.scoreBarX =
					scoreBar.x -
					daJsonScore.scoreBarXPlus;

				daJsonScore.scoreBarY =
					scoreBar.y -
					daJsonScore.scoreBarYPlus;

				if (ClientPrefs.data.downScroll)
				{
					daJsonScore.scoreBarYDownscroll =
						scoreBar.y -
						daJsonScore.scoreBarYPlus;
				}

			case "scoreText":
				daJsonScore.x =
					scoreTxt.x -
					daJsonScore.xPlus;

				daJsonScore.y =
					scoreTxt.y -
					daJsonScore.yPlus;

				if (ClientPrefs.data.downScroll)
				{
					daJsonScore.yDownscroll =
						scoreTxt.y -
						daJsonScore.yPlus;
				}
		}
	}

	public function saveJson()
	{
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