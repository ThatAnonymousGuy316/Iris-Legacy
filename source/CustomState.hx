package;

import haxe.Json;

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
    public var stateObjects:FlxTypedGroup<FlxBasic> = [];
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