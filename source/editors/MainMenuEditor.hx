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
import flixel.addons.display.FlxBackdrop;

using StringTools;

#if MODS_ALLOWED
import sys.FileSystem;
#end

import MainMenuState;

typedef MenuEditAction = {
	var index:Int;
	var name:String;
	var x:Float;
	var y:Float;
	var goesToState:Bool;
}

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

	var undoStack:Array<MenuEditAction> = [];
	var redoStack:Array<MenuEditAction> = [];

    var allowMenuItemMove:FlxButton;
    var allowBackgroundMove:FlxButton;
    var reloadImage:FlxButton;
    var backgroundText:FlxText;

    var reloadImageFlash:FlxButton;
    var backgroundTextFlash:FlxText;

	var saveButton:FlxButton;
	var undoButton:FlxButton;
	var redoButton:FlxButton;

	var changeVersion:FlxButton;
	var versionText:FlxUIInputText;
    var versionTextA:FlxText;

	var addObject:FlxButton;
	var objectText:FlxUIInputText;
    var objectTextA:FlxText;
	var editorPanelBG:FlxSprite;

	var checkeredBg:FlxBackdrop;
	var editorBG:FlxSprite;

	var objectCheckState:FlxUICheckBox;
	public var doesObjectGoToState:Bool = true;

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = true;

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

		var yScroll:Float = 0.25;
		editorBG = new FlxSprite(-150, -150).makeGraphic(FlxG.width + 300, FlxG.height + 300, 0xFF808080);
		editorBG.scrollFactor.set(0, yScroll);
		editorBG.visible = false;
		add(editorBG);

		var tileSize:Int = 80;
		var tempSprite:FlxSprite = new FlxSprite().makeGraphic(tileSize * 2, tileSize * 2, FlxColor.TRANSPARENT);
		tempSprite.pixels.fillRect(new openfl.geom.Rectangle(0, 0, tileSize, tileSize), FlxColor.WHITE);
		tempSprite.pixels.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), FlxColor.WHITE);

		checkeredBg = new FlxBackdrop(tempSprite.graphic, XY, 0, 0);
		checkeredBg.scrollFactor.set(0, yScroll);
		checkeredBg.velocity.set(45, 45);
		checkeredBg.alpha = FlxG.random.float(0.06, 0.12);
		checkeredBg.visible = false;
		add(checkeredBg);

		editorPanelBG = new FlxSprite(10, 10).makeGraphic(530, 250, FlxColor.BLACK);
		editorPanelBG.alpha = 0.5;
		editorPanelBG.scrollFactor.set();
		add(editorPanelBG);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
        
		rebuildMenuItems();

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

		undoButton = new FlxButton(
			imageBackgroundInput.x + 400,
			imageBackgroundInput.y + 50,
			"Undo",
			function()
			{
				undoAction();
			}
		);

		redoButton = new FlxButton(
			imageBackgroundInput.x + 400,
			imageBackgroundInput.y + 75,
			"Redo",
			function()
			{
				redoAction();
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

		objectCheckState.callback = function()
		{
			doesObjectGoToState = objectCheckState.checked;
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
				menuJson.options.push(newObject);

				rebuildMenuItems();
			}
		);

		add(imageBackgroundInput);
		add(reloadImage);
		add(allowBackgroundMove);
		add(allowMenuItemMove);

		add(imageBackgroundInputFlash);
		add(reloadImageFlash);
		add(saveButton);
		add(undoButton);
		add(redoButton);

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

	function rebuildMenuItems()
	{
		menuItems.clear();
		for (i in 0...optionShit.length)
		{
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
		handleUndoRedoShortcuts();

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		}

		if (FlxG.keys.justPressed.F2)
		{
			substates.HELPSubState.helpText = 
				"MAIN MENU EDITOR\n\n" +
				"- Press ESCAPE to hide the UI.\n" +
				"- Click 'BG Move' to drag the background.\n" +
				"- Click 'Item Move' to drag menu items.\n" +
				"- Right-Click an item to delete it.\n" +
				"- Ctrl+Z / Undo button to Undo deletion.\n" +
				"- Ctrl+Y / Redo button to Redo deletion.\n" +
				"- Don't forget to Save!";
			
			editorBG.visible = true;
			checkeredBg.visible = true;
			openSubState(new substates.HELPSubState());
		}
		
		if (FlxG.keys.justPressed.F1)
		{
			var panelVisible:Bool = !editorPanelBG.visible;

			editorPanelBG.visible = panelVisible;
			imageBackgroundInput.visible = panelVisible;
			reloadImage.visible = panelVisible;
			allowBackgroundMove.visible = panelVisible;
			allowMenuItemMove.visible = panelVisible;
			backgroundText.visible = panelVisible;
			imageBackgroundInputFlash.visible = panelVisible;
			reloadImageFlash.visible = panelVisible;
			backgroundTextFlash.visible = panelVisible;
			saveButton.visible = panelVisible;
			undoButton.visible = panelVisible;
			redoButton.visible = panelVisible;
			changeVersion.visible = panelVisible;
			versionText.visible = panelVisible;
			versionTextA.visible = panelVisible;
			addObject.visible = panelVisible;
			objectText.visible = panelVisible;
			objectTextA.visible = panelVisible;
			objectCheckState.visible = panelVisible;
		}
	}

	override public function closeSubState()
	{
		super.closeSubState();
		editorBG.visible = false;
		checkeredBg.visible = false;
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
					var opt = menuJson.options[i];
					var action:MenuEditAction = {
						index: i,
						name: opt.name,
						x: opt.x,
						y: opt.y,
						goesToState: opt.goesToState
					};
					undoStack.push(action);
					redoStack = []; // Clear redo history on new deletion action

					menuItems.remove(item, true);
					menuJson.options.splice(i, 1);
					optionShit.splice(i, 1);

					if (draggedItem == item)
					{
						draggingItem = false;
						draggedItem = null;
					}

					rebuildMenuItems();
					break;
				}
			}
		}
	}

	function undoAction()
	{
		if (undoStack.length > 0)
		{
			var action = undoStack.pop();
			redoStack.push(action);

			var optData = {
				name: action.name,
				x: action.x,
				y: action.y,
				goesToState: action.goesToState
			};

			if (action.index <= menuJson.options.length)
			{
				menuJson.options.insert(action.index, optData);
				optionShit.insert(action.index, action.name);
			}
			else
			{
				menuJson.options.push(optData);
				optionShit.push(action.name);
			}

			rebuildMenuItems();
		}
	}

	function redoAction()
	{
		if (redoStack.length > 0)
		{
			var action = redoStack.pop();
			undoStack.push(action);

			if (action.index < menuJson.options.length && menuJson.options[action.index].name == action.name)
			{
				menuJson.options.splice(action.index, 1);
				optionShit.splice(action.index, 1);
			}
			else
			{
				for (i in 0...menuJson.options.length)
				{
					if (menuJson.options[i].name == action.name)
					{
						menuJson.options.splice(i, 1);
						optionShit.splice(i, 1);
						break;
					}
				}
			}

			rebuildMenuItems();
		}
	}

	function handleUndoRedoShortcuts()
	{
		var controlPressed:Bool = FlxG.keys.pressed.CONTROL;

		// Undo: Ctrl + Z
		if (controlPressed && FlxG.keys.justPressed.Z)
		{
			undoAction();
		}

		// Redo: Ctrl + Y
		if (controlPressed && FlxG.keys.justPressed.Y)
		{
			redoAction();
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