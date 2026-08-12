package;

import hxscript.Script;

import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.ds.IntMap;

import sys.FileSystem;
import sys.io.File;

import flixel.FlxG;

using StringTools;

class FunkinHXC
{
    public var script:Script;

    public function new(filePath:String)
    {
        script = new Script(File.getContent(filePath), haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(filePath)));
        script.start();
        script.call('onCreate');
    }

    public function set(name:String, data:Dynamic)
    {
        script.variables.set(name, data);
    }
}