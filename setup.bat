@echo off
echo Installing Haxelib dependencies...

haxelib install lime 8.0.1
haxelib install openfl 9.3.2
haxelib install flixel 5.5.0
haxelib install flixel-addons 3.2.1
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.5.0
haxelib install hxcpp-debug-server 1.2.4
haxelib install tjson 1.4.0
haxelib install hxCodec 2.6.1
haxelib install hxdiscord_rpc 1.2.4

echo Installing hscript...
haxelib install hscript

echo Installing Git dependencies...

haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 8c20c7adcb7ce9d7ebc83de10208bff96e3cb5d0

haxelib git fnf-modcharting-tools https://github.com/EdwhakKB/FNF-Modcharting-Tools

haxelib git hxscript https://github.com/MeguminBOT/hxscript

echo.
echo Done!
pause