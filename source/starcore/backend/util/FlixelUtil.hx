package starcore.backend.util;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Exception;
import openfl.filters.ShaderFilter;
import starcore.backend.api.DiscordClient;
import starcore.backend.data.ClientPrefs.ShaderModeType;
import starcore.backend.data.Constants;
import starcore.shaders.*;
#if SOUND_FILTERS_ALLOWED
import flixel.sound.filters.FlxFilteredSound;
import flixel.sound.filters.FlxSoundFilter;
import flixel.sound.filters.effects.FlxSoundReverbEffect;
#end
#if html5
import js.Browser;
#end
#if (mac || linux)
import sys.io.Process;
#end

// Directly inject C++ code for
// detecting if caps lock is enabled
// on Windows/C++ builds
#if cpp
@:headerCode('
    extern "C" bool hx_isCapsLockOn();
')
@:cppFileCode('
    #include <windows.h>
    extern "C" bool hx_isCapsLockOn() {
        return (GetKeyState(VK_CAPITAL) & 0x0001) != 0;
    }
')
#end

/**
 * Utility class for handling objects and components specific to Flixel.
 */
final class FlixelUtil
{
	function new() {}

	/**
	 * Fades into a state with a cool transition effect.
	 * 
	 * @param state             The states to switch to.
	 * @param duration          How long it takes to switch from one state to the next state.
	 * @param playTransitionSfx Should the game play a sound when it switches states?
	 */
	public static function fadeIntoState(state:FlxState, duration:Float, playTransitionSfx:Bool = true):Void
	{
		if (playTransitionSfx)
		{
			FlxG.sound.play(PathUtil.ofSharedSound(''), 1, false, false);
		}

		FlxG.camera.fade(FlxColor.BLACK, duration, false, () ->
		{
			FlxG.switchState(() -> state);
		});
	}

	/**
	 * Play a sound with an echo, cave-like sound effect.
	 * 
	 * @param path      The path to the sound to play.
	 * @param volume    The volume of the sound.
	 * @param decayTime How long it echoes for.
	 */
	public static function playSoundWithReverb(path:String, volume:Float = 1, decayTime:Float = 4):Void
	{
		#if SOUND_FILTERS_ALLOWED
		if (!(CacheUtil.currentReverbSoundsAmount >= Constants.REVERB_SOUND_EFFECT_LIMIT))
		{
			var sound:FlxFilteredSound = new FlxFilteredSound();
			var effect:FlxSoundReverbEffect = new FlxSoundReverbEffect();

			// Settings for the reverb
			effect.decayTime = decayTime;

			sound.loadEmbedded(path);
			sound.filter = new FlxSoundFilter();
			sound.filter.addEffect(effect);
			// Add the sound to the game so that way it
			// gets lowered when the game loses focus and
			// the user has 'minimizeVolume' enabled
			FlxG.sound.list.add(sound);

			sound.play();
			CacheUtil.currentReverbSoundsAmount++;
			// Recycle the sound after it finishes playing
			new FlxTimer().start((sound.length / 1000) + (decayTime / 1.85), (_) ->
			{
				sound.filter.clearEffects();
				sound.filter = null;
				FlxG.sound.list.remove(sound, true);
				FlxG.sound.list.recycle(FlxSound);
				sound.destroy();
				CacheUtil.currentReverbSoundsAmount--;
			});
		}
		#else
		FlxG.sound.play(path, volume);
		#end
	}

	/**
	 * Play menu music ***if*** it hasn't already started.
	 * 
	 * @param volume How loud the menu music should be.
	 */
	public static function playMenuMusic(volume:Float = 1):Void
	{
		if (CacheUtil.canPlayMenuMusic)
		{
			FlxG.sound.playMusic(PathUtil.ofSharedMusic(Constants.MENU_MUSIC_NAME), volume, true);
			CacheUtil.canPlayMenuMusic = false;
		}
	}

	/**
	 * Stops all sounds that are currently playing.
	 * 
	 * @param stopMusic Should the music be stopped as well? Default value is `true`.
	 */
	public static function stopAllSounds(stopMusic:Bool = true):Void
	{
		if (FlxG.sound.music != null && FlxG.sound.music.exists && stopMusic)
		{
			FlxG.sound.music.stop();
		}

		for (sound in FlxG.sound.list.members)
		{
			if (sound != null && sound.exists)
			{
				sound.stop();
			}
		}
	}

	/**
	 * Sets the game's filters.
	 * 
	 * @param mode The mode the filters should apply with.
	 * 			   Check `starcore.backend.ClientPrefs.ShaderModeType` for
	 * 			   what each mode means. `null` = `DEFAULT`.
	 */
	public static function setFilters(?mode:ShaderModeType):Void
	{
		switch (mode)
		{
			#if ADVANCED_SHADERS_ALLOWED
			case ShaderModeType.DEFAULT | null:
				FlxG.game.setFilters([
					new ShaderFilter(CacheUtil.vcrBorderShader),
					new ShaderFilter(CacheUtil.vcrMario85Shader),
					new ShaderFilter(CacheUtil.grainShader),
					new ShaderFilter(new Hq2xShader()),
					new ShaderFilter(new TiltshiftShader())
				]);
			#end
			case ShaderModeType.FAST:
				FlxG.game.setFilters([
					new ShaderFilter(CacheUtil.grainShader),
					new ShaderFilter(new ScanlineShader()),
					new ShaderFilter(new Hq2xShader()),
					new ShaderFilter(new TiltshiftShader())
				]);
			case ShaderModeType.MINIMAL:
				FlxG.game.setFilters([
					new ShaderFilter(CacheUtil.grainShader),
					new ShaderFilter(new Hq2xShader())
				]);
			case ShaderModeType.NONE:
				FlxG.game.setFilters([]);
			default:
				FlxG.game.setFilters([]);
		}
	}

	/**
	 * Get's the last key that was pressed on the current frame.
	 * 
	 * @return The last key that was pressed. If no keys were pressed, then
	 *         `FlxKey.NONE` is returned instead.
	 */
	public static function getLastKeyPressed():FlxKey
	{
		for (key in 8...303) // Loop through all keys in FlxKey
		{
			try
			{
				if (FlxG.keys.anyJustPressed([key]))
				{
					return key;
				}
			}
			catch (e:Exception)
			{
				// Skip and move on if it is not a valid key
			}
		}
		return FlxKey.NONE;
	}

	/**
	 * Get's the current keys that were just pressed on the current frame.
	 * 
	 * @return All `FlxKey`s that were just pressed. If no keys were pressed, then
	 *         an empty array (`[]`) is returned instead.
	 */
	public static function getCurrentKeysJustPressed():Array<FlxKey>
	{
		var toReturn:Array<FlxKey> = [];
		for (key in 8...303) // Loop through all keys in FlxKey
		{
			try
			{
				if (FlxG.keys.anyJustPressed([key]))
				{
					toReturn.push(key);
				}
			}
			catch (e:Exception)
			{
				// Skip and move on if it is not a valid key
			}
		}
		return toReturn;
	}

	/**
	 * Get's the current keys that are held down on the current frame.
	 * 
	 * @return All `FlxKey`s that are currently held down. If no keys are pressed, then
	 *         an empty array (`[]`) is returned instead.
	 */
	public static function getCurrentKeysPressed():Array<FlxKey>
	{
		var toReturn:Array<FlxKey> = [];
		for (key in 8...303) // Loop through all keys in FlxKey
		{
			try
			{
				if (FlxG.keys.anyPressed([key]))
				{
					toReturn.push(key);
				}
			}
			catch (e:Exception)
			{
				// Skip and move on if it is not a valid key
			}
		}
		return toReturn;
	}

	/**
	 * Converts an `FlxKey` constant to it's respective character.
	 * 
	 * ## Examples
	 * ```
	 * convertFlxKeyToChar(FlxKey.THREE) -> '3'
	 * convertFlxKeyToChar(FlxKey.SEMICOLON) -> ';'
	 * convertFlxKeyToChar(FlxKey.BACKSLASH) -> '\\'
	 * ```
	 * 
	 * ### *NOTE: If `FlxKey.PLUS` is passed down, it will be returned as `=` if `shiftVariant` is false!*
	 * 
	 * @param key          The key to be converted.
	 * @param shiftVariant If the key should be converted to the variant when the
	 *                     user is pressing shift (i.e. `a` would become `A`, `;` would
	 *                     become `:`, etc.). Default value is `false`.
	 * @return             The converted character.
	 */
	public static function convertFlxKeyToChar(key:FlxKey, shiftVariant:Bool = false):String
	{
		var toReturn:String;

		switch (key)
		{
			case ZERO:
				toReturn = '0';
			case ONE:
				toReturn = '1';
			case TWO:
				toReturn = '2';
			case THREE:
				toReturn = '3';
			case FOUR:
				toReturn = '4';
			case FIVE:
				toReturn = '5';
			case SIX:
				toReturn = '6';
			case SEVEN:
				toReturn = '7';
			case EIGHT:
				toReturn = '8';
			case NINE:
				toReturn = '9';
			case NUMPADZERO:
				toReturn = '0';
			case NUMPADONE:
				toReturn = '1';
			case NUMPADTWO:
				toReturn = '2';
			case NUMPADTHREE:
				toReturn = '3';
			case NUMPADFOUR:
				toReturn = '4';
			case NUMPADFIVE:
				toReturn = '5';
			case NUMPADSIX:
				toReturn = '6';
			case NUMPADSEVEN:
				toReturn = '7';
			case NUMPADEIGHT:
				toReturn = '8';
			case NUMPADNINE:
				toReturn = '9';
			case NUMPADPLUS:
				toReturn = '+';
			case NUMPADMINUS:
				toReturn = '-';
			case NUMPADMULTIPLY:
				toReturn = '*';
			case NUMPADSLASH:
				toReturn = '/';
			case NUMPADPERIOD:
				toReturn = '.';
			case SEMICOLON:
				toReturn = ';';
			case COMMA:
				toReturn = ',';
			case PERIOD:
				toReturn = '.';
			case SLASH:
				toReturn = '/';
			case GRAVEACCENT:
				toReturn = '`';
			case LBRACKET:
				toReturn = '[';
			case RBRACKET:
				toReturn = ']';
			case BACKSLASH:
				toReturn = '\\';
			case QUOTE:
				toReturn = '\'';
			case PLUS: // Why can't it be "EQUALS"...
				toReturn = '=';
			case MINUS:
				toReturn = '-';
			default:
				toReturn = key.toString().toLowerCase();
		}

		return (!shiftVariant) ? toReturn : convertCharToShiftChar(toReturn);
	}

	/**
	 * Converts a `String` char to it's respective shifted character.
	 * 
	 * ## Examples
	 * ```
	 * convertCharToShiftChar('3') -> '*'
	 * convertCharToShiftChar(';') -> ':'
	 * convertCharToShiftChar('\\') -> '|'
	 * ```
	 * 
	 * @param key The key to be converted.
	 * @return    The converted character (as its shift variant).
	 */
	public static function convertCharToShiftChar(key:String):String
	{
		switch (key)
		{
			case '1':
				return '!';
			case '2':
				return '@';
			case '3':
				return '#';
			case '4':
				return '$';
			case '5':
				return '%';
			case '6':
				return '^';
			case '7':
				return '&';
			case '8':
				return '*';
			case '9':
				return '(';
			case '0':
				return ')';
			case ';':
				return ':';
			case ',':
				return '<';
			case '.':
				return '>';
			case '/':
				return '?';
			case '`':
				return '~';
			case '[':
				return '{';
			case ']':
				return '}';
			case '\\':
				return '|';
			case '\'':
				return '"';
			case '=':
				return '+';
			case '-':
				return '_';
			default:
				return key.toUpperCase();
		}
	}

	/**
	 * Gets if caps lock is enabled.
	 * Only works on HTML5, Windows, macOS and Linux builds.
	 * 
	 * @return If caps lock is enabled.
	 */
	public static inline function getCapsLockEnabled():Bool
	{
		#if html5
		return untyped __js__('window.__haxe_capslock__');
		#elseif cpp
		return untyped __cpp__('hx_isCapsLockOn()');
		#elseif mac
		try
		{
			var proc:Process = new Process('bash', ['-c', 'osascript -e \'tell application \'System Events\' to get caps lock']);
			var result:String = proc.stdout.readLine();
			proc.close();
			return result == 'true';
		}
		catch (e:Dynamic)
		{
			return false;
		}
		#elseif linux
		try
		{
			var proc:Process = new Process('bash', ['-c', 'xset q | grep Caps']);
			var output:String = proc.stdout.readAll().toString();
			proc.close();
			return output.indexOf('on') != -1;
		}
		catch (e:Dynamic)
		{
			return false;
		}
		#else
		return false;
		#end
	}

	/**
	 * Tweens an `FlxTypedGroup<FlxSprite>`'s members with ease.
	 * 
	 * @param group    The group to tween.
	 * @param options  Dynamic object with the attributes to tween.
	 * @param duration How long the tween should last for.
	 * @param types    The types and eases for the group to tween with.
	 */
	public static function tweenSpriteGroup(group:FlxTypedGroup<FlxSprite>, options:Dynamic, duration:Float, types:Dynamic):Void
	{
		for (obj in group.members)
		{
			if (obj != null)
			{
				FlxTween.tween(obj, options, duration, types);
			}
		}
	}

	/**
	 * Close the entire game.
	 * 
	 * @param sysShutdown Whether to close the game using the dedicated platform
	 * 					  shutdown method or not. Set this to `false` when you
	 *                    just need to save the user's data and shutdown the utilities and
	 *                    wish to shut the game down another way (i.e. throwing an exception).
	 */
	public static function closeGame(sysShutdown:Bool = true):Void
	{
		// Log info
		LoggerUtil.log('SHUTTING DOWN STARCORE', INFO, false);
		// Save all of the user's data
		SaveUtil.saveAll();
		// Shutdown Discord rich presence
		DiscordClient.shutdown();
		// Shutdown the logging system
		LoggerUtil.shutdown();
		// Close the game respectfully
		if (sysShutdown)
		{
			#if web
			Browser.window.close();
			#elseif desktop
			Sys.exit(0);
			#end
		}
	}

	/**
	 * Crashes the game and throws an exception with an error message.
	 * 
	 * @param errorMsg The message to be displayed on the error window.
	 */
	public static function crashGame(errorMsg:String):Void
	{
		LoggerUtil.log(errorMsg, ERROR, false);
		closeGame(false);
		throw new Exception(errorMsg);
	}
}
