package funkin.backend;

import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Exception;

import flixel.FlxG;

import lime.system.System;

import openfl.system.System as OpenFlSystem;

using StringTools;

enum AudioStatus {
    PAUSE;
    RESUME;
    STOP;
}

class CrashHandler
{
    static final LOGS_DIR = "logs/";
    
    public static function init():Void
    {
        try {
            openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
            #if cpp
            untyped __global__.__hxcpp_set_critical_error_handler(onError);
            #elseif hl
            hl.Api.setErrorHandler(onError);
            #end
        } catch (e:Exception) {
            trace("Failed to initialize crash handler: " + e.message);
        }
    }

    private static function onUncaughtError(e:UncaughtErrorEvent):Void
    {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        var message = parseErrorMessage(e.error);
        var stack = formatExceptionStack(haxe.CallStack.exceptionStack());
        
        handleCrash(message, stack);
    }

    #if (cpp || hl)
    private static function onError(message:Dynamic):Void
    {
        var log = [];
        if (message != null && Std.string(message).length > 0)
            log.push(Std.string(message));
            
        log.push(formatExceptionStack(haxe.CallStack.exceptionStack(true)));
        handleCrash(log.join('\n'), "");
    }
    #end

    private static function parseErrorMessage(error:Dynamic):String
    {
        return if (Std.isOfType(error, Error)) {
            cast(error, Error).message;
        } else if (Std.isOfType(error, ErrorEvent)) {
            cast(error, ErrorEvent).text;
        } else {
            Std.string(error);
        }
    }

    private static function formatExceptionStack(stack:Array<haxe.CallStack.StackItem>):String {
        var result = "";
        for (item in stack) {
            switch(item) {
                case FilePos(item, file, line):
                    result += 'at ${formatStackItem(item)} ($file: $line line)\n';
                    
                case Method(classname, method):
                    result += 'in ${classname}.$method\n';
                    
                case Module(module):
                    result += 'in module $module\n';
                    
                case CFunction:
                    result += "in C function\n";
                    
                case _:
                    result += 'in ${Std.string(item)}\n';
            }
        }
        return result;
    }

    private static function formatStackItem(item:haxe.CallStack.StackItem):String {
        return switch(item) {
            case Method(classname, method): '$classname.$method';
            case Module(module): 'module $module';
            case CFunction: "C function";
            case FilePos(_, file, line): '$file:$line';
            case _: Std.string(item);
        };
    }

    private static function handleCrash(message:String, stack:String):Void
    {
        var fullError = 'CRASH DETAILS:\n$message\n\nSTACK TRACE:\n$stack';
        
        #if sys
        saveCrashLog(fullError);
        #end
        
        switchAudioStatus(PAUSE);
        showErrorPopup(fullError);
        
        #if sys
        System.exit(1);
        #elseif js
        js.Browser.window.location.reload();
        #end
    }

    private static function switchAudioStatus(status:AudioStatus):Void
    {
        switch(status)
        {
            case PAUSE:
                FlxG.sound?.music?.pause();
                if (FlxG.sound != null && FlxG.sound.list != null) {
                    for (sound in FlxG.sound.list) {
                        if (sound != null && sound.playing) {
                            sound.pause();
                        }
                    }
                }
            case RESUME:
                FlxG.sound?.music?.resume();
                if (FlxG.sound != null && FlxG.sound.list != null) {
                    for (sound in FlxG.sound.list) {
                        if (sound != null && sound.playing) {
                            sound.resume();
                        }
                    }
                }
            case STOP:
                FlxG.sound?.music?.stop();
                if (FlxG.sound != null && FlxG.sound.list != null) {
                    for (sound in FlxG.sound.list) {
                        if (sound != null && sound.playing) {
                            sound.stop();
                        }
                    }
                }
        }
    }

    private static function showErrorPopup(message:String):Void
    {
        try {
            CoolUtil.showPopUp(message, "Error!", #if sl_windows_api MSG_ERROR #end);
        } catch (e:Dynamic) {
            trace("Failed to show error popup: " + e);
        }
    }

    #if sys
    private static function saveCrashLog(content:String):Void
    {
        try {
            if (!FileSystem.exists(LOGS_DIR)) {
                FileSystem.createDirectory(LOGS_DIR);
            }
            
            var now = Date.now();
            var timestamp = '${now.getFullYear()}-${lpad(Std.string(now.getMonth() + 1), "0", 2)}'
                + '-${lpad(Std.string(now.getDate()), "0", 2)}_${lpad(Std.string(now.getHours()), "0", 2)}'
                + '-${lpad(Std.string(now.getMinutes()), "0", 2)}-${lpad(Std.string(now.getSeconds()), "0", 2)}';
            
            var fileName = LOGS_DIR + 'crash_$timestamp.txt';
            
            var logContent = new StringBuf();
            logContent.add('======================= CRASH LOG =======================\n\n');
            logContent.add('CRASH TIME: ${now.toString()}\n');
            
            File.saveContent(fileName, logContent.toString());
        } catch (e:Exception) {
            trace('Failed to save crash log: ${e.message}');
        }
    }
    
    private static function lpad(value:String, pad:String, length:Int):String 
    {
        while (value.length < length) value = pad + value;
        return value;
    }
    #end
}