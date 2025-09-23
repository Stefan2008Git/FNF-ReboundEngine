package funkin.data;

#if DISCORD_ALLOWED
import cpp.Function;
import flixel.util.FlxStringUtil;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import lime.app.Application;
import Sys.sleep;
import sys.thread.Thread;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	private inline static final _defaultID:String = "1059518348196597831";
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordRichPresence = new DiscordRichPresence();
	@:unreflective private static var __thread:Thread;

	public static function check()
	{
        if (!isInitialized) initialize(); else shutdown();
	}

	public static function prepare()
	{
		if (!isInitialized) initialize();

		Application.current.window.onClose.add(function() {
			if(isInitialized) shutdown();
		});
	}

	public dynamic static function shutdown()
	{
		isInitialized = false;
		Discord.Shutdown();
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final user = cast (request[0].username, String);
		final discriminator = cast (request[0].discriminator, String);

		var message = '(Discord) Connected to User ';
		if (discriminator != '0') message += '($user#$discriminator)'; else message += '($user)';

		trace(message);
		changePresence();
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Error ($errorCode: ${cast(message, String)})');
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Disconnected ($errorCode: ${cast(message, String)})');
	}

	public static function initialize()
	{
		final discordHandlers:DiscordEventHandlers = #if (hxdiscord_rpc > "1.2.4") new DiscordEventHandlers(); #else DiscordEventHandlers.create(); #end
		discordHandlers.ready = Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), #if (hxdiscord_rpc > "1.2.4") false #else 1 #end, null);

		if(!isInitialized) trace("Discord Client initialized");

		if (__thread == null)
		{
			__thread = Thread.create(() ->
			{
				while (true)
				{
					if (isInitialized)
					{
						#if DISCORD_DISABLE_IO_THREAD
						Discord.UpdateConnection();
						#end
						Discord.RunCallbacks();
					}
					Sys.sleep(2);
				}
			});
		}
		isInitialized = true;
	}

	public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, largeImageKey:String = 'icon')
	{
		var startTimestamp:Float = 0;
		if (hasStartTimestamp) startTimestamp = Date.now().getTime();
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		presence.state = state;
		presence.details = details;
		presence.smallImageKey = smallImageKey;
		presence.largeImageKey = largeImageKey;
		presence.largeImageText = "Rebound Engine v" + MainMenuState.engineVersion;
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);

		final button:DiscordButton = new DiscordButton();
		button.label = "FNF' Rebound Engine";
		button.url = "https://github.com/Stefan2008Git/FNF-ReboundEngine";
		presence.buttons[0] = button;

		final button2:DiscordButton = new DiscordButton();
		button2.label = "Stefan's YT";
		button2.url = "https://www.youtube.com/@stefan2008_official";
		presence.buttons[1] = button2;
		updatePresence();
	}

	public static function updatePresence()
	{
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}

	inline public static function resetClientID()
	{
		clientID = _defaultID;
	}

	private static function set_clientID(newID:String)
	{
		var change:Bool = (clientID != newID);
		clientID = newID;

		if(change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}
		return newID;
	}
}
#end
