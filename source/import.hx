#if !macro
// Flixel
#if (flixel >= '5.3.0')
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;

// Data
import funkin.data.*;
import funkin.data.Discord.DiscordClient;
import funkin.data.characters.*;

// Others
import funkin.backend.*;
import funkin.backend.objects.*;

// Shaders
import funkin.data.shaders.*;

// Scripts
import funkin.scripts.*;

// Stages and Objects
import funkin.data.stages.*;

// States
import funkin.states.*;
import funkin.states.menus.*;
import funkin.states.options.*;
import funkin.states.editors.*;
import ui.*;

// SubStates
import funkin.substates.*;

// Controls
import funkin.controls.Controls;
import funkin.controls.InputFormatter;

#if mobile
import funkin.mobile.*;
import funkin.mobile.controls.flixel.*;
import funkin.mobile.controls.*;
#end
#end
