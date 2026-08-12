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

    var freeplaySongs:Array<String> = [];

    var diffColor = [FlxColor.GREEN, FlxColor.YELLOW, FlxColor.RED, FlxColor.PINK, FlxColor.PURPLE];

    public var curDifficulty:Int = -1;

    public var grpSongs:FlxTypedGroup<FlxText>;

    var diffTextPlus = 175;

    var freeplaySelector:FlxSprite;

    var curSelected:Int = 0;
    var listOffset:Float = 0;
    var spacing:Float = 80;

    var difficultyText:FlxSprite;

    var leftDiffSel:FlxSprite;
    var rightDiffSel:FlxSprite;

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
                freeplaySongs.push(song[0]);
            }
        }

        WeekData.loadTheFirstEnabledMod();

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.antialiasing = ClientPrefs.data.globalAntialiasing;
        bg.updateHitbox();
        bg.color = 0xFFea71fd;
        add(bg);

        grpSongs = new FlxTypedGroup<FlxText>();
        add(grpSongs);

        for (i in 0...freeplaySongs.length)
        {
            var songText = new FlxText(0, i * 80, 0, "", 20);
            songText.setFormat(Paths.font("pah.ttf"), 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            songText.scrollFactor.set();
            songText.borderSize = 1.25;
            songText.text = freeplaySongs[i];
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

        difficultyText = new FlxSprite(leftDiffSel.x + 65);
        difficultyText.frames = Paths.getSparrowAtlas('freeplay/difficulty');
        difficultyText.animation.addByPrefix('easy', 'EASY', 24, false);
        difficultyText.animation.addByPrefix('normal', 'NORMAL', 24, false);
        difficultyText.animation.addByPrefix('hard', 'HARD', 24, false);
        difficultyText.animation.addByPrefix('erect', 'ERECT', 24, false);
        difficultyText.animation.addByPrefix('nightmare', 'NIGHTMARE', 24, false);
        difficultyText.animation.addByPrefix('mercy', 'MERCY', 24, false);
        difficultyText.animation.play('normal');
        add(difficultyText);

        curDifficulty = CoolUtil.difficulties.indexOf(CoolUtil.defaultDifficulty);

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

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (controls.UI_UP_P || controls.UI_DOWN_P) changeDiff();
    }

    function changeDiff(change:Int = 0)
    {
        curDifficulty += change;

        if (curDifficulty < 0)
            curDifficulty = CoolUtil.difficulties.length - 1;

        if (curDifficulty >= CoolUtil.difficulties.length)
            curDifficulty = 0;

        PlayState.storyDifficulty = curDifficulty;

        difficultyText.animation.play(CoolUtil.difficulties[curDifficulty].toLowerCase());
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
    }

    function weekIsLocked(name:String):Bool
    {
        var leWeek:WeekData = WeekData.weeksLoaded.get(name);
        return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
    }
}