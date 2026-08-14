package;

import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.ds.IntMap;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;

import sys.FileSystem;
import sys.io.File;

import flixel.FlxG;

using StringTools;

class FunkinHScript
{
    public var parser:Parser;
    public var interp:Interp;

    public static var ext:String = 'hxs';

    public function new(filePath:String)
    {
        parser = new Parser();
        interp = new Interp();
        new FunkinHScriptPreset(this);
		parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;
        interp.execute(parser.parseString(File.getContent(filePath), filePath));
        call('onCreate', []);
    }

    public function set(name:String, arg:Dynamic){interp.variables.set(name, arg);}

    public function call(name:String, ?args:Array<Dynamic>)
    {
        if (!interp.variables.exists(name))
            return null;

        var func:Dynamic = interp.variables.get(name);

        if (!Reflect.isFunction(func))
            return null;

        return Reflect.callMethod(null, func, args);
    }
}