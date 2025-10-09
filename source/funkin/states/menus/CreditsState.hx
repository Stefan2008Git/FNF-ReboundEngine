package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class CreditsState extends MusicBeatState
{
    // Base menu stuff
    var bg:FlxSprite;
    var intendedColor:FlxColor;
    var checker:FlxBackdrop;
    var button:FlxSprite;
    var bottomBG:FlxSprite;
    var title:Alphabet;
    var bottomTitle:Alphabet;

    // Credit stuff (['Your name of icon', 'Actual name of you', 'Your descritpion', 'Your color id', 'Your social media link'])
    var creditsName:FlxText;
    var creditsDesc:FlxText;
    var creditsIcon:FlxSprite;
    var creditsList:Array<Array<String>> = [
       ['stefan', 'Stefan2008', 'Owner of Rebound #1', '4400bd', 'https://www.youtube.com/@stefan2008_official'],
       ['maysLastPlays', 'MaysLastPlay', 'Owner of Rebound #2', '1fe1de', 'https://www.youtube.com/@MaysLastPlay'],
       ['greenColdTea', 'JustX', 'Programmer for Rebound', '2c81b7', 'https://github.com/GreenColdTea'],
    ];
    var creditsGroup:FlxTypedGroup<FlxSprite>;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;
    var currentSelector:Int = 0; // This will select a icon if of mentioned string from credits list. Default it will give Stefan2008 because id is 0. --Stefan2008

    override public function create()
    {
        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Credits Menu", null);
		#end

        FlxG.mouse.visible = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.alpha = 0.8;
		add(bg);

		checker = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, FlxColor.BLACK, 0x0));
        checker.velocity.set(18, 18);
        checker.screenCenter();
        checker.alpha = 0.6;
        add(checker);

		creditsGroup = new FlxTypedGroup<FlxSprite>();
		add(creditsGroup);

		for (i in 0...creditsList.length)
		{
            creditsIcon = new FlxSprite(50 + (i * 140), 0).loadGraphic(Paths.image("menus/creditsMenu/credits/" + creditsList[i][0]));
            creditsIcon.scale.set(0.3, 0.3);
            creditsIcon.x = 510;
            creditsIcon.y = 220;
            creditsIcon.updateHitbox();
            creditsIcon.ID = i;
            creditsGroup.add(creditsIcon);
		}

		bottomBG = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 200, 0xFF000000);
        bottomBG.alpha = 0.6;
        add(bottomBG);

        title = new Alphabet(0, 0, "CREDITS", true);
        title.scrollFactor.set(0, 0);
        title.antialiasing = true;
        title.screenCenter(X);
        title.y = FlxG.height - 700;
        add(title);

		creditsName = new FlxText(0, 0, FlxG.width, "");
		creditsName.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        creditsName.scrollFactor.set(0, 0);
        creditsName.borderSize = 2;
        creditsName.antialiasing = true;
        creditsName.screenCenter(X);
        creditsName.y = FlxG.height - 490;
        add(creditsName);

        creditsDesc = new FlxText(0, 0, FlxG.width, "");
        creditsDesc.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        creditsDesc.scrollFactor.set(0, 0);
        creditsDesc.borderSize = 2;
        creditsDesc.antialiasing = true;
        creditsDesc.screenCenter(X);
        creditsDesc.y = FlxG.height - 38;
        add(creditsDesc);

		leftArrow = new FlxSprite();
		leftArrow.frames = FlxAtlasFrames.fromSparrow("assets/images/creditsMenu/arrows.png", "assets/images/creditsMenu/arrows.xml");
		leftArrow.screenCenter();
		leftArrow.animation.addByPrefix('leftIdle', "arrow left", 24);
		leftArrow.animation.addByPrefix('pressLeft', "arrow push left", 24);
		leftArrow.x = 50;
		leftArrow.animation.play('leftIdle');
		leftArrow.updateHitbox();
		add(leftArrow);

		rightArrow = new FlxSprite();
		rightArrow.frames = FlxAtlasFrames.fromSparrow("assets/images/creditsMenu/arrows.png", "assets/images/creditsMenu/arrows.xml");
		rightArrow.screenCenter();
		rightArrow.animation.addByPrefix('rightIdle', "arrow right", 24);
		rightArrow.animation.addByPrefix('pressRight', "arrow push right", 24, false);
		rightArrow.x += 550;
		rightArrow.animation.play('rightIdle');
		rightArrow.updateHitbox();
		add(rightArrow);

        changeTheSelection(0);
        intendedColor = bg.color;

		super.create();
    }

    var textFloater:Float = 0;
    override public function update(elapsed:Float)
    {
        textFloater += elapsed;
        creditsName.y = 190 + (Math.sin(textFloater) * 1 ) * 10;

        if (controls.BACK) 
        {
            FlxG.mouse.visible = false;
            FlxG.switchState(() -> new MainMenuState());
        }

        creditsGroup.forEach(function(member:FlxSprite)
        {
            var distItem:Int = -1;

            if (FlxG.mouse.overlaps(member))
            {
                distItem = member.ID;
                currentSelector = distItem;

                if (FlxG.mouse.justPressed)
                {
                   CoolUtil.openURL(creditsList[currentSelector][4]);
                }
            }
        });

        if (FlxG.mouse.overlaps(leftArrow)) {
            if (FlxG.mouse.justPressed) changeTheSelection(-1);
        } else if (FlxG.mouse.overlaps(rightArrow)) {
            if (FlxG.mouse.justPressed) changeTheSelection(1);
        }

        super.update(elapsed);
    }

    function changeTheSelection(changer:Int = 0)
    {
        currentSelector += changer;

        if (currentSelector >= creditsGroup.length - 1) currentSelector = creditsGroup.length - 1; else if (currentSelector <= 0) currentSelector = 0;

        creditsGroup.forEach(function(spr:FlxSprite)
        {
            spr.y += 400;
            spr.kill();
            spr.updateHitbox();

            leftArrow.animation.play('leftIdle');
            rightArrow.animation.play('rightIdle');

            if (spr.ID == currentSelector)
            {
                spr.revive();
                spr.updateHitbox();
                spr.screenCenter();
                leftArrow.animation.play("pressLeft");
                rightArrow.animation.play("pressRight");
            }
            spr.centerOffsets();
        });

        creditsName.text = creditsList[currentSelector][1];
        creditsDesc.text = creditsList[currentSelector][2];

        var newColor:FlxColor = CoolUtil.colorFromString(creditsList[currentSelector][3]);
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 0.5, bg.color, intendedColor);
		}
    }
}
