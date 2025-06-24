package starcore.backend.util;

using StringTools;

/**
 * Utility class for manipulating data in `String`s,
 * `Array`s, `Dynamic` JSON data, or anything similar.
 */
final class DataUtil
{
	function new() {}

	/**
	 * Inserts string `toInsert` inside of string `s` based on the index.
	 * 
	 * ## Example
	 * ```
	 * var s:String = 'This is so cool!';
	 * insertStringAtIndex(s, 'function ', 4); // Output: This function is so cool! 
	 * ```
	 * 
	 * @param s        The string to be changed.
	 * @param toInsert The string to insert.
	 * @param index    The index to insert `toInsert`.
	 * @return         The modified string.
	 */
	public static function insertStringAtIndex(s:String, toInsert:String, index:Int):String
	{
		var toReturn:String = '';
		var toConcat:Array<String> = [];
		// Add all characters to the list
		// (including the string to insert at the wanted index)
		for (i in 0...s.length)
		{
			toConcat.push(s.charAt(i));
			if (i == index)
			{
				toConcat.push(toInsert);
			}
		}
		// Reconstruct the string back with the inserted text
		for (char in toConcat)
		{
			toReturn += char;
		}
		return toReturn;
	}

	/**
	 * Deletes a specific part of text from string `s` 
	 * based on `startIndex` and `endIndex`.
	 * 
	 * If `startIndex` is greater than `endIndex`, then the numbers are swapped.
	 * 
	 * ## Example
	 * ```
	 * var s:String = 'The word "not" is not deleted!';
	 * deleteTextFromString(s, 18, 21); // Output: The word "not" is deleted!
	 * ```
	 * 
	 * @param s          The string to delete text from.
	 * @param startIndex The starting index to delete text from.
	 * @param endIndex   The ending index to delete text from (inclusive).
	 * @return           The modified string.
	 */
	public static function deleteTextFromString(s:String, startIndex:Int, endIndex:Int):String
	{
		var si:Int = (!(startIndex > endIndex)) ? startIndex : endIndex;
		var ei:Int = (!(startIndex > endIndex)) ? endIndex : startIndex;
		var toReturn:String = '';
		for (i in 0...s.length)
		{
			// If the current character isn't in the range of
			// the text to be "deleted", then add the character
			// at the end of toReturn
			if (!(i >= si && i <= ei))
			{
				toReturn += s.charAt(i);
			}
		}
		return toReturn;
	}

	/**
	 * Removes a word from a string by its index.
	 * 
	 * ## Example
	 * ```
	 * var s:String = 'The second word will be removed!';
	 * trace(removeWordFromIndex(s, 1)); // Output: "The word will be removed!"
	 * ```
	 * 
	 * @param s         The string to remove the indexed word from.
	 * @param index     The index of the word to remove.
	 * @param delimiter How the words should be separated. A space (`' '`) is the default value.
	 * @param trim      Should the returned string trim its whitespace?
	 * @return          The new string (without the removed word).
	 */
	public static function removeWordFromIndex(s:String, index:Int, delimiter:String = ' ', trim:Bool = true):String
	{
		// Remove the word by the said index
		var toReturn:String = '';
		var sentence:Array<String> = s.trim().split(delimiter);
		// Convert it back to a regular string, but
		// without the removed word
		for (word in 0...sentence.length)
		{
			if (word != index)
			{
				toReturn += '${sentence[word]} ';
			}
		}
		return (trim) ? toReturn.trim() : return toReturn;
	}

	/**
	 * Get a dynamic value from a `Dynamic` object. Note that this is meant 
	 * for JSON specific objects.
	 * 
	 * @param object       The JSON `Dynamic` object to obtain the field from.
	 * @param field        The field to get.
	 * @param defaultValue The value that is returned if the field does not exist. Default value is `null`.
	 * @return             The value found from the said field. If it isn't found, then the
	 *                     `defaultValue` parameter is returned instead.
	 */
	public static inline function getDynamicField(object:Dynamic, field:String, ?defaultValue:Dynamic):Any
	{
		return (Reflect.hasField(object, field)) ? Reflect.field(object, field) : defaultValue;
	}

	/**
	 * Cleans an array by removing all `null` values from it.
	 * 
	 * @param array The array to clean.
	 * @return      The cleaned array.
	 */
	public static function cleanArray(array:Array<Any>):Array<Any>
	{
		var toReturn:Array<Any> = [];
		for (item in array)
		{
			if (item != null)
			{
				toReturn.push(item);
			}
		}
		return toReturn;
	}
}
