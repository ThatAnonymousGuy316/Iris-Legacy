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

    public var stateObjects:FlxTypedGroup<FlxSprite>;
    public var stateVariables:Map<String, FlxBasic> = new Map<String, FlxBasic>();

    var bg:FlxSprite;

    var draggedObject:FlxSprite = null;
    var itemDragOffsetX:Float = 0;
	var itemDragOffsetY:Float = 0;

    var epicGroup:FlxSpriteGroup;

    var selectedObject:FlxSprite = null;

    var addObjectInputText:FlxUIInputText;
    var addObjectInputText2:FlxUIInputText;
    var addObjectInputText3:FlxUIInputText;
    var addObjectInputText4:FlxUIInputText;
    var addObjectInputText5:FlxUIInputText;

    var objecthasFramesCheck:FlxUICheckBox;
    var animationLoopCheck:FlxUICheckBox;

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

        stateObjects = new FlxTypedGroup<FlxSprite>();
        add(stateObjects);

        epicGroup = new FlxSpriteGroup();
        add(epicGroup);

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
                sprite.loadGraphic(Paths.image(object.texture));

            sprite.alpha = object.alpha;
            sprite.antialiasing = ClientPrefs.data.globalAntialiasing;

            sprite.scale.x = object.scale;
            sprite.scale.y = object.scale;

            stateObjects.add(sprite);
            stateVariables.set(object.name, sprite);

            daJson.objects.push({
                name: object.name,
                hasFrames: object.hasFrames,
                animationPrefix: object.animationPrefix,
                animationLoops: object.animationLoops,
                animationFramerate: object.animationFramerate,
                texture: object.texture,
                x: object.x,
                y: object.y,
                alpha: object.alpha,
                scale: object.scale
            });
        }

        addObjectInputText = new FlxUIInputText(
			15,
			30,
			200,
			"",
			8
		);

        addObjectInputText2 = new FlxUIInputText(
            15,
            60,
            200,
            "1",
            8
        );

        addObjectInputText3 = new FlxUIInputText(
            15,
            90,
            200,
            "1",
            8
        );

        addObjectInputText4 = new FlxUIInputText(
            15,
            120,
            200,
            "",
            8
        );

        addObjectInputText5 = new FlxUIInputText(
            15,
            150,
            200,
            "24",
            8
        );

        var stateNameText = new FlxUIInputText(
			15,
			180,
			200,
			"",
			8
		);

        objecthasFramesCheck = new FlxUICheckBox(
            10 + 70,
            addObjectInputText3.y + 50,
            null,
            null,
            "Object Has Frames?",
            100
        );

        animationLoopCheck = new FlxUICheckBox(
            10 + 70,
            objecthasFramesCheck.y + 50,
            null,
            null,
            "Animation Loops?",
            100
        );

		var addObjectButton = new FlxButton(
			addObjectInputText.x + 210,
			addObjectInputText.y - 3,
			"Add Object",
			function()
			{
                createObject(addObjectInputText.text, 
                    addObjectInputText.text, 0, 0, 
                    Std.parseFloat(addObjectInputText2.text), 
                    Std.parseFloat(addObjectInputText3.text), 
                    objecthasFramesCheck.checked, 
                    addObjectInputText4.text,
                    Std.parseInt(addObjectInputText5.text),
                    animationLoopCheck.checked
                );
			}
		);

		var saveButton = new FlxButton(
			addObjectButton.x + 100,
			addObjectButton.y,
			"Save",
			function()
			{
                saveJson(stateNameText.text);
			}
		);

		var loadButton = new FlxButton(
			saveButton.x + 100,
			saveButton.y,
			"load",
			function()
			{
                load(stateNameText.text);
			}
		);
        objecthasFramesCheck.x = addObjectButton.x;
        objecthasFramesCheck.y = addObjectInputText.y + 20;
		objecthasFramesCheck.checked = false;

        animationLoopCheck.x = addObjectButton.x;
        animationLoopCheck.y = objecthasFramesCheck.y + 20;
		animationLoopCheck.checked = false;

        epicGroup.add(addObjectInputText);
        epicGroup.add(addObjectInputText2);
        epicGroup.add(addObjectInputText3);
        epicGroup.add(addObjectInputText4);
        epicGroup.add(addObjectInputText5);
        epicGroup.add(stateNameText);
        epicGroup.add(objecthasFramesCheck);
        epicGroup.add(animationLoopCheck);
        epicGroup.add(addObjectButton);
        epicGroup.add(saveButton);
        epicGroup.add(loadButton);
        epicGroup.add(new FlxText(15,addObjectInputText.y - 16,0,'Name/Texture:'));
        epicGroup.add(new FlxText(15,addObjectInputText2.y - 16,0,'Alpha:'));
        epicGroup.add(new FlxText(15,addObjectInputText3.y - 16,0,'Scale:'));
        epicGroup.add(new FlxText(15,addObjectInputText4.y - 16,0,'Animation Prefix/Name:'));
        epicGroup.add(new FlxText(15,addObjectInputText5.y - 16,0,'Animation Framerate:'));
        epicGroup.add(new FlxText(15,stateNameText.y - 16,0,'State Name (For Saving and Loading):'));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		}
        handleMovingObjects(elapsed);
    }

    public function handleMovingObjects(elapsed:Float)
    {
        if (FlxG.mouse.justPressedRight)
        {
            for (object in stateObjects)
            {
                if (FlxG.mouse.overlaps(object))
                {
                    stateObjects.remove(object, true);
                    
                    for (name => variable in stateVariables)
                    {
                        if (variable == object)
                        {
                            stateVariables.remove(name);
                            break;
                        }
                    }
                    
                    for (i in 0...daJson.objects.length)
                    {
                        if (daJson.objects[i].name == null)
                            continue;

                        if (stateVariables.exists(daJson.objects[i].name) == false)
                        {
                            daJson.objects.splice(i, 1);
                            break;
                        }
                    }

                    if (draggedObject == object)
                        draggedObject = null;

                    break;
                }
            }
        }
        if (FlxG.mouse.justPressed)
        {
            for (object in stateObjects)
            {
                if (FlxG.mouse.overlaps(object))
                {
                    selectedObject = object;

                    draggedObject = object;

                    itemDragOffsetX = FlxG.mouse.x - object.x;
                    itemDragOffsetY = FlxG.mouse.y - object.y;

                    for (data in daJson.objects)
                    {
                        if (stateVariables.exists(data.name) && stateVariables.get(data.name) == object)
                        {
                            addObjectInputText.text = data.name;
                            addObjectInputText2.text = Std.string(data.alpha);
                            addObjectInputText3.text = Std.string(data.scale);
                            addObjectInputText4.text = data.animationPrefix;
                            addObjectInputText5.text = Std.string(data.animationFramerate);

                            objecthasFramesCheck.checked = data.hasFrames;
                            animationLoopCheck.checked = data.animationLoops;

                            break;
                        }
                    }

                    break;
                }
            }
        }

        if (FlxG.mouse.pressed && draggedObject != null)
        {
            draggedObject.x = FlxG.mouse.x - itemDragOffsetX;
            draggedObject.y = FlxG.mouse.y - itemDragOffsetY;

            for (i in 0...daJson.objects.length)
            {
                if (stateVariables.exists(daJson.objects[i].name) && stateVariables.get(daJson.objects[i].name) == draggedObject)
                {
                    daJson.objects[i].x = draggedObject.x;
                    daJson.objects[i].y = draggedObject.y;
                    break;
                }
            }
        }

        if (FlxG.mouse.justReleased)
        {
            draggedObject = null;
        }
    }

    public function createObject(name:String, texture:String, x:Float, y:Float, ?alpha:Float = 1, ?scale:Float = 1, ?hasFrames:Bool = false, ?animationPrefix:String, ?animationFramerate:Int, ?animationLoops:Bool)
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
            sprite.loadGraphic(Paths.image(texture));

        sprite.alpha = alpha;
        sprite.antialiasing = ClientPrefs.data.globalAntialiasing;

        sprite.scale.x = scale;
        sprite.scale.y = scale;

        stateObjects.add(sprite);
        stateVariables.set(name, sprite);

        daJson.objects.push({
            name: name,
            hasFrames: hasFrames,
            animationPrefix: animationPrefix,
            animationLoops: animationLoops,
            animationFramerate: animationFramerate,
            texture: texture,
            x: x,
            y: y,
            alpha: alpha,
            scale: scale
        });
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
        var loadedJson:StateJson = Json.parse(Paths.getTextFromFile('states/${stateName}.json'));

        stateObjects.clear();
        stateVariables.clear();

        selectedObject = null;
        draggedObject = null;

        daJson = loadedJson;

        optionShit = [];

        for (object in daJson.objects)
            optionShit.push(object.name);

        if (daJson.backgroundTexture != null && daJson.backgroundTexture != '')
        {
            if (bg == null)
            {
                bg = new FlxSprite();
                bg.antialiasing = ClientPrefs.data.globalAntialiasing;
                add(bg);
            }

            bg.visible = true;
            bg.loadGraphic(Paths.image(daJson.backgroundTexture));
            bg.x = daJson.backgroundX;
            bg.y = daJson.backgroundY;
            bg.alpha = daJson.backgroundAlpha;
        }
        else if (bg != null)
        {
            bg.visible = false;
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
            {
                sprite.loadGraphic(Paths.image(object.texture));
            }

            sprite.alpha = object.alpha;
            sprite.antialiasing = ClientPrefs.data.globalAntialiasing;

            sprite.scale.x = object.scale;
            sprite.scale.y = object.scale;

            stateObjects.add(sprite);
            stateVariables.set(object.name, sprite);
        }
    }
}