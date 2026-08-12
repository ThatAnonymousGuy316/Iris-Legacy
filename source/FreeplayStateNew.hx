package;

#if hxdiscord_rpc
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.sound.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayStateNew extends MusicBeatState
{
    override function create()
    {
        super.create();
        onCreate();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        onUpdate(elapsed);
    }

    var bg:FlxSprite;

    var freeplaySongs:Array<{
        name:String,
        character:String,
        folder:String
    }> = [];

    var diffColor = [FlxColor.GREEN, FlxColor.YELLOW, FlxColor.RED, FlxColor.PINK, FlxColor.PURPLE];

    public static var curDifficulty:Int = 1;

    public var grpSongs:FlxTypedGroup<FlxText>;

    var diffTextPlus = 175;

    var freeplaySelector:FlxSprite;

    public static var curSelected:Int = 0;
    var listOffset:Float = 0;
    var spacing:Float = 80;

    var difficultyText:FlxSprite;

    var leftDiffSel:FlxSprite;
    var rightDiffSel:FlxSprite;

    var freeplayArtwork:FlxSprite;

    function onCreate()
    {
        WeekData.reloadWeekFiles(false);

        for (i in 0...WeekData.weeksList.length)
        {
            if (weekIsLocked(WeekData.weeksList[i])) continue;

            var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
            var leSongs:Array<String> = [];
            var leChars:Array<String> = [];

            for (j in 0...leWeek.songs.length)
            {
                leSongs.push(leWeek.songs[j][0]);
                leChars.push(leWeek.songs[j][1]);
            }

            WeekData.setDirectoryFromWeek(leWeek);

            for (song in leWeek.songs)
            {
                freeplaySongs.push({
                    name: song[0],
                    character: song[1],
                    folder: Paths.currentModDirectory
                });
            }
        }

        WeekData.loadTheFirstEnabledMod();

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.antialiasing = ClientPrefs.data.globalAntialiasing;
        bg.updateHitbox();
        add(bg);

        freeplayArtwork = new FlxSprite(560).loadGraphic(Paths.image('freeplay/artwork/dad'));
        freeplayArtwork.antialiasing = ClientPrefs.data.globalAntialiasing;
        freeplayArtwork.alpha = 0.5;
        freeplayArtwork.updateHitbox();
        add(freeplayArtwork);

        grpSongs = new FlxTypedGroup<FlxText>();
        add(grpSongs);

        for (i in 0...freeplaySongs.length)
        {
            var songText = new FlxText(0, i * 80, 0, "", 20);
            songText.setFormat(Paths.font("pah.ttf"), 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            songText.scrollFactor.set();
            songText.borderSize = 1.25;
            songText.text = freeplaySongs[i].name;
            grpSongs.add(songText);
        }

        freeplaySelector = new FlxSprite();
        freeplaySelector.frames = Paths.getSparrowAtlas('freeplay/freeplaySelector');
        freeplaySelector.animation.addByPrefix('idle', 'arrow pointer loop', 24, true);
        freeplaySelector.animation.play('idle');
        add(freeplaySelector);

        var bfdj = new FlxSprite(870, 340);
        bfdj.frames = Paths.getSparrowAtlas('freeplay/bfdj/idle');
        bfdj.animation.addByPrefix('idle', 'Boyfriend DJ', 24, true);
        bfdj.animation.play('idle');
        add(bfdj);

        leftDiffSel = new FlxSprite(560);
        leftDiffSel.frames = Paths.getSparrowAtlas('freeplay/freeplaySelector');
        leftDiffSel.animation.addByPrefix('idle', 'arrow pointer loop', 24, true);
        leftDiffSel.animation.play('idle');
        add(leftDiffSel);

        difficultyText = new FlxSprite(leftDiffSel.x + 65, 10);
        difficultyText.loadGraphic(Paths.image('freeplay/difficulties/NORMAL'));
        add(difficultyText);

        rightDiffSel = new FlxSprite(difficultyText.x + 240);
        rightDiffSel.frames = Paths.getSparrowAtlas('freeplay/freeplaySelector');
        rightDiffSel.animation.addByPrefix('idle', 'arrow pointer loop', 24, true);
        rightDiffSel.animation.play('idle');
        rightDiffSel.flipX = true;
        add(rightDiffSel);

        if (curDifficulty < 0)
            curDifficulty = 0;

        updateList();
        changeDiff();
    }

    function onUpdate(elapsed:Float)
    {
        handleActions(elapsed);
    }

    function handleActions(elapsed:Float)
    {
        if (controls.BACK)
        {
            persistentUpdate = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

        if (FlxG.keys.justPressed.CONTROL)
        {
            persistentUpdate = false;
            openSubState(new GameplayChangersSubstate());
        }

        if (controls.UI_UP_P)
        {
            curSelected--;

            if (curSelected < 0)
                curSelected = freeplaySongs.length - 1;

            updateList();
        }

        if (controls.UI_DOWN_P)
        {
            curSelected++;

            if (curSelected >= freeplaySongs.length)
                curSelected = 0;

            updateList();
        }

        if (controls.ACCEPT)
        {
            onAccept();
        }

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (controls.UI_UP_P || controls.UI_DOWN_P) changeDiff();
    }

    function onAccept()
    {
        persistentUpdate = false;

        Paths.currentModDirectory = freeplaySongs[curSelected].folder;

        var songLowercase:String = Paths.formatToSongPath(freeplaySongs[curSelected].name);
        var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

        trace('Song: ' + songLowercase);
        trace('Mod directory: ' + Paths.currentModDirectory);

        PlayState.SONG = Song.loadFromJson(poop, songLowercase);
        PlayState.isStoryMode = false;
        PlayState.storyDifficulty = curDifficulty;

        LoadingState.loadAndSwitchState(new PlayState());

        FlxG.sound.music.volume = 0;
    }

    function changeDiff(change:Int = 0)
    {
        curDifficulty += change;

        if (curDifficulty < 0)
            curDifficulty = CoolUtil.difficulties.length - 1;

        if (curDifficulty >= CoolUtil.difficulties.length)
            curDifficulty = 0;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
        }

        difficultyText.loadGraphic(Paths.image('freeplay/difficulties/${CoolUtil.difficulties[curDifficulty].toUpperCase()}'));

        PlayState.storyDifficulty = curDifficulty;
    }

    function updateList()
    {
        listOffset = (FlxG.height / 2) - (curSelected * spacing);

        for (i in 0...grpSongs.members.length)
        {
            grpSongs.members[i].y = (i * spacing) + listOffset;
        }

        var selectedSong:FlxText = grpSongs.members[curSelected];

        freeplaySelector.x = selectedSong.x + selectedSong.width + 10;
        freeplaySelector.y = selectedSong.y;

        bg.loadGraphic(Paths.image('freeplay/bgs/${freeplaySongs[curSelected].character}'));
        freeplayArtwork.loadGraphic(Paths.image('freeplay/artwork/${freeplaySongs[curSelected].character}'));
    }

    function weekIsLocked(name:String):Bool
    {
        var leWeek:WeekData = WeekData.weeksLoaded.get(name);
        return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
    }
}