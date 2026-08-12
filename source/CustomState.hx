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

}