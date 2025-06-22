package starcore.backend.util;

import flixel.FlxG;
import haxe.Json;
import openfl.utils.Assets;

/**
 * Utility class for obtaining and manipulating data from files.
 */
final class AssetUtil
{
	function new() {}

	/**
	 * Removes the file extension from the passed down file name.
	 * 
	 * @param fileName The file name.
	 * @return         The file name (but with the extension removed).
	 */
	public static function removeFileExtension(fileName:String):String
	{
		var dotIndex:Int = fileName.lastIndexOf(".");
		return (dotIndex > 0) ? fileName.substr(0, dotIndex) : fileName;
	}

	/**
	 * Generate a random string for a new file (this is mainly used for
	 * new log files).
	 * 
	 * @return A new random file name.
	 */
	public static function generateRandomFileName():String
	{
		var chars:String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
		var result:StringBuf = new StringBuf();
		for (_ in 0...chars.length)
		{
			var index:Int = Std.int(Math.random() * chars.length);
			result.add(chars.charAt(index));
		}
		return result.toString();
	}

	/**
	 * Gets regular JSON data from the specified file pathway.
	 * 
	 * @param path        The pathway to obtain the JSON data.
	 * @param defaultData The data that is returned if the `.json` file does not exist.
	 * @return            The data that was obtained from the said file. If it was not found, then `null` is returned instead.
	 */
	public static inline function getJsonData(path:String, ?defaultData:Dynamic):Dynamic
	{
		return (Assets.exists(path)) ? Json.parse(Assets.getText(path)) : defaultData;
	}

	/**
	 * Caches a list of sounds from an `Array`.
	 * 
	 * @param soundArray The list of the file pathways for each sound file to precache.
	 */
	public static function precacheSoundArray(soundArray:Array<String>):Void
	{
		for (snd in soundArray)
		{
			FlxG.sound.cache(snd);
		}
	}
}
