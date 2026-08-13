package editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUICheckBox;
import haxe.Json;

using StringTools;

#if MODS_ALLOWED
import sys.FileSystem;
#end

import MainMenuState;

class MainMenuEditor extends MusicBeatState
{
	var bg:FlxSprite;

	var menuJson:MainMenuJson;

	var imageBackgroundInput:FlxUIInputText;
	var imageBackgroundInputFlash:FlxUIInputText;
	var menuItems:FlxTypedGroup<FlxSprite>;

	var canBackgroundMove:Bool = false;
	var canMenuItemMove:Bool = false;

	var optionShit:Array<String> = [];

	var draggingBg:Bool = false;
	var bgDragOffsetX:Float = 0;
	var bgDragOffsetY:Float = 0;

	var draggingItem:Bool = false;
	var draggedItem:FlxSprite = null;
	var itemDragOffsetX:Float = 0;
	var itemDragOffsetY:Float = 0;

    var allowMenuItemMove:FlxButton;
    var allowBackgroundMove:FlxButton;
    var reloadImage:FlxButton;
    var backgroundText:FlxText;

    var reloadImageFlash:FlxButton;
    var backgroundTextFlash:FlxText;

	var saveButton:FlxButton;

	var changeVersion:FlxButton;
	var versionText:FlxUIInputText;
    var versionTextA:FlxText;

	var addObject:FlxButton;
	var objectText:FlxUIInputText;
    var objectTextA:FlxText;
	var editorPanelBG:FlxSprite;

	var objectCheckState:FlxUICheckBox;

	public var doesObjectGoToState:Bool = true;

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		// Add a semi-transparent black box behind the editor UI controls
		var editorPanelBG:FlxSprite = new FlxSprite(10, 10).makeGraphic(540, 250, FlxColor.BLACK);
		editorPanelBG.alpha = 0.65;
		editorPanelBG.scrollFactor.set();
		add(editorPanelBG);

		menuJson = Json.parse(Paths.getTextFromFile('states/_override/MainMenuState.json'));

		optionShit = [];
		for (option in menuJson.options)
		{
			optionShit.push(option.name);
		}

		bg = new FlxSprite(menuJson.backgroundX, menuJson.backgroundY);
		bg.loadGraphic(Paths.image(menuJson.background));
		bg.antialiasing = ClientPrefs.data.globalAntialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		// Initialize the class variable here
		editorPanelBG = new FlxSprite(10, 10).makeGraphic(530, 250, FlxColor.BLACK);
		editorPanelBG.alpha = 0.5; // Slight tint transparency
		editorPanelBG.scrollFactor.set();
		add(editorPanelBG);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
        

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

			var menuItem = new FlxSprite(
				menuJson.options[i].x,
				menuJson.options[i].y
			);

			menuItem.antialiasing = ClientPrefs.data.globalAntialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);

			menuItem.animation.addByPrefix(
				'idle',
				optionShit[i] + " basic",
				24
			);

			menuItem.animation.addByPrefix(
				'selected',
				optionShit[i] + " white",
				24
			);

			menuItem.animation.play('idle');

			var scroll:Float = (optionShit.length - 4) * 0.135;

			if (optionShit.length < 6)
				scroll = 0;

			menuItem.scrollFactor.set(0, scroll);
			menuItem.updateHitbox();

			menuItems.add(menuItem);
		}

		imageBackgroundInput = new FlxUIInputText(
			15,
			30,
			200,
			menuJson.background,
			8
		);

		reloadImage = new FlxButton(
			imageBackgroundInput.x + 210,
			imageBackgroundInput.y - 3,
			"Change BG",
			function()
			{
				bg.loadGraphic(Paths.image(imageBackgroundInput.text));
				bg.antialiasing = ClientPrefs.data.globalAntialiasing;
			}
		);

		imageBackgroundInputFlash = new FlxUIInputText(
			15,
			90,
			200,
			menuJson.backgroundFlash,
			8
		);

		reloadImageFlash = new FlxButton(
			imageBackgroundInputFlash.x + 210,
			imageBackgroundInputFlash.y - 3,
			"Change Flash",
			function()
			{
				menuJson.backgroundFlash = imageBackgroundInputFlash.text;
			}
		);

		allowBackgroundMove = new FlxButton(
			imageBackgroundInput.x + 310,
			imageBackgroundInput.y - 3,
			"BG Move",
			function()
			{
				canBackgroundMove = !canBackgroundMove;
				canMenuItemMove = false;

				if (!canBackgroundMove)
					draggingBg = false;
			}
		);

		allowMenuItemMove = new FlxButton(
			imageBackgroundInput.x + 310,
			imageBackgroundInput.y + 25,
			"Item Move",
			function()
			{
				canMenuItemMove = !canMenuItemMove;
				canBackgroundMove = false;

				if (!canMenuItemMove)
				{
					draggingItem = false;
					draggedItem = null;
				}
			}
		);

		saveButton = new FlxButton(
			imageBackgroundInput.x + 310,
			imageBackgroundInput.y + 50,
			"Save",
			function()
			{
				saveJson();
			}
		);

		versionText = new FlxUIInputText(
			15,
			130,
			200,
			menuJson.version,
			8
		);

		changeVersion = new FlxButton(
			versionText.x + 210,
			versionText.y - 3,
			"Change Ver",
			function()
			{
				menuJson.version = versionText.text;
			}
		);

		objectText = new FlxUIInputText(
			15,
			170,
			200,
			"",
			8
		);

		objectCheckState = new FlxUICheckBox(10, objectText.y + 50, null, null, "Object Goes To A State?", 100);
		objectCheckState.checked = doesObjectGoToState;
		// _song.needsVoices = check_voices.checked;
		objectCheckState.callback = function()
		{
			doesObjectGoToState = objectCheckState.checked;
			//trace('CHECKED!');
		};

		addObject = new FlxButton(
			objectText.x + 210,
			objectText.y - 3,
			"Add Object",
			function()
			{
				var newObject:OptionDataJson = {
					goesToState: objectCheckState.checked,
					name: objectText.text,
					x: 0,
					y: 0,
				};
				optionShit.push(newObject.name);
				var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

				var menuItem = new FlxSprite(
					newObject.x,
					newObject.y
				);

				menuItem.antialiasing = ClientPrefs.data.globalAntialiasing;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + newObject.name);

				menuItem.animation.addByPrefix(
					'idle',
					newObject.name + " basic",
					24
				);

				menuItem.animation.addByPrefix(
					'selected',
					newObject.name + " white",
					24
				);

				menuItem.animation.play('idle');

				var scroll:Float = (optionShit.length - 4) * 0.135;

				if (optionShit.length < 6)
					scroll = 0;

				menuItem.scrollFactor.set(0, scroll);
				menuItem.updateHitbox();

				menuItems.add(menuItem);

				menuJson.options.push(newObject);
			}
		);

		add(imageBackgroundInput);
		add(reloadImage);
		add(allowBackgroundMove);
		add(allowMenuItemMove);

		add(imageBackgroundInputFlash);
		add(reloadImageFlash);
		add(saveButton);

		add(versionText);
		add(changeVersion);

		add(objectText);
		add(addObject);
		add(objectCheckState);

        backgroundText = new FlxText(
            15,
            imageBackgroundInput.y - 18,
            0,
            'Background image file name:'
        );

        add(backgroundText);

		backgroundTextFlash = new FlxText(
            15,
            imageBackgroundInputFlash.y - 18,
            0,
            'Background Flash image file name:'
        );

		add(backgroundTextFlash);

		versionTextA = new FlxText(
            15,
            versionText.y - 18,
            0,
            'Version:'
        );

		add(versionTextA);

		objectTextA = new FlxText(
            15,
            objectText.y - 18,
            0,
            'Object Name:'
        );

		add(objectTextA);

	}

    public function saveJson()
    {
        var saveFolder:String = Sys.getCwd() + "/game/states/_override";

        if (!FileSystem.exists(saveFolder))
            FileSystem.createDirectory(saveFolder);

        File.saveContent(
            saveFolder + "/MainMenuState.json",
            Json.stringify(menuJson, null, "\t")
        );
        trace("Saved JSON files to: " + saveFolder);
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		handleBackgroundDragging();
		handleMenuItemDragging();
		handleMenuItemRemoval();

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		}

		// --- F1: OPEN HELP MENU ---
		if (FlxG.keys.justPressed.F1)
		{
			// Set the static text for the Main Menu Editor
			substates.HELPSubState.helpText = 
				"MAIN MENU EDITOR\n\n" +
				"- Press F2 to hide the UI.\n" +
				"- Click 'BG Move' to drag the background.\n" +
				"- Click 'Item Move' to drag menu items.\n" +
				"- Right-Click an item to delete it.\n" +
				"- Don't forget to Save!";
			
			openSubState(new substates.HELPSubState());
		}

		// --- F2: HIDE/SHOW UI ---
		if (FlxG.keys.justPressed.F2)
		{
			editorPanelBG.visible = !editorPanelBG.visible;
			imageBackgroundInput.visible = !imageBackgroundInput.visible;
			reloadImage.visible = !reloadImage.visible;
			allowBackgroundMove.visible = !allowBackgroundMove.visible;
			allowMenuItemMove.visible = !allowMenuItemMove.visible;
			backgroundText.visible = !backgroundText.visible;
			imageBackgroundInputFlash.visible = !imageBackgroundInputFlash.visible;
			reloadImageFlash.visible = !reloadImageFlash.visible;
			backgroundTextFlash.visible = !backgroundTextFlash.visible;
			saveButton.visible = !saveButton.visible;
			changeVersion.visible = !changeVersion.visible;
			versionText.visible = !versionText.visible;
			versionTextA.visible = !versionTextA.visible;
			addObject.visible = !addObject.visible;
			objectText.visible = !objectText.visible;
			objectTextA.visible = !objectTextA.visible;
			objectCheckState.visible = !objectCheckState.visible;
		}
	}

	function handleMenuItemRemoval()
	{
		if (FlxG.mouse.justPressedRight)
		{
			for (i in 0...menuItems.members.length)
			{
				var item = menuItems.members[i];

				if (item != null && FlxG.mouse.overlaps(item))
				{
					menuItems.remove(item, true);
					menuJson.options.splice(i, 1);
					optionShit.splice(i, 1);

					if (draggedItem == item)
					{
						draggingItem = false;
						draggedItem = null;
					}

					break;
				}
			}
		}
	}

	function handleBackgroundDragging()
	{
		if (!canBackgroundMove)
			return;

		if (FlxG.mouse.pressed && !draggingBg)
		{
			if (FlxG.mouse.overlaps(bg))
			{
				draggingBg = true;

				bgDragOffsetX = FlxG.mouse.x - bg.x;
				bgDragOffsetY = FlxG.mouse.y - bg.y;
			}
		}

		if (!FlxG.mouse.pressed)
		{
			draggingBg = false;
			return;
		}

		if (draggingBg)
		{
			bg.x = FlxG.mouse.x - bgDragOffsetX;
			bg.y = FlxG.mouse.y - bgDragOffsetY;

			menuJson.backgroundX = bg.x;
			menuJson.backgroundY = bg.y;
		}
	}

	function handleMenuItemDragging()
	{
		if (!canMenuItemMove)
			return;

		if (FlxG.mouse.pressed && !draggingItem)
		{
			for (item in menuItems)
			{
				if (FlxG.mouse.overlaps(item))
				{
					draggingItem = true;
					draggedItem = item;

					itemDragOffsetX = FlxG.mouse.x - item.x;
					itemDragOffsetY = FlxG.mouse.y - item.y;

					break;
				}
			}
		}

		if (!FlxG.mouse.pressed)
		{
			draggingItem = false;
			draggedItem = null;
			return;
		}

		if (draggingItem && draggedItem != null)
		{
			draggedItem.x = FlxG.mouse.x - itemDragOffsetX;
			draggedItem.y = FlxG.mouse.y - itemDragOffsetY;
			
			for (i in 0...menuItems.members.length)
			{
				if (menuItems.members[i] == draggedItem)
				{
					menuJson.options[i].x = draggedItem.x;
					menuJson.options[i].y = draggedItem.y;
					break;
				}
			}
		}
	}
}
