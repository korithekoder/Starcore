package starcore.backend.api;

import starcore.backend.data.WindowData;

/**
 * Class for interacting with the C++ API with ease.
 * This is mostly for handling specifically things with 
 * the game's window.
 */
class CppAPI
{
	/**
	 * Gets the amount of installed RAM in MB.
	 * 
	 * @return The amount of installed RAM in MB.
	 */
	public static function getInstalledRam():Int
	{
		return WindowData.getInstalledRam();
	}

	/**
	 * Enables dark mode for the window.
	 */
	public static function enableDarkMode():Void
	{
		WindowData.setWindowColorMode(DARK);
	}

	/**
	 * Enables light mode for the window.
	 */
	public static function enableLightMode():Void
	{
		WindowData.setWindowColorMode(LIGHT);
	}

	/**
	 * Sets the window's background alpha value.
	 * 
	 * @param a The value to set the window's background alpha to.
	 *          This value should be between 0 and 1.
	 */
	public static function setWindowOpacity(a:Float):Void
	{
		WindowData.setWindowAlpha(a);
	}

	/**
	 * Sets the window to be layered.
	 * This allows for transparency effects to be applied.
	 */
	public static function setWindowLayered():Void
	{
		WindowData.setWindowLayered();
	}

	/**
	 * Sets the user's wallpaper from a given path.
	 * 
	 * @param path The path to the wallpaper image.
	 *             If the path is 'old', it will set the wallpaper to the previous state.
	 *             If the path is null, it will do nothing.
	 */
	public static function setWallpaper(path:String):Void
	{
		#if cpp
		if (path == 'old')
		{
			if (Wallpaper.oldWallpaper != null)
			{
				path = Wallpaper.oldWallpaper;
			}
			else
			{
				return;
			}
		}
		Wallpaper.setWallpaper(path);
		#end
	}

	/**
	 * Sets the wallpaper to the previous or old state.
	 */
	public static function setOld():Void
	{
		#if cpp
		Wallpaper.setOld();
		#end
	}

	/**
	 * Hides the Windows taskbar.
	 */
	public static function hideTaskbar():Void
	{
		WindowData.hideTaskbar();
	}

	/**
	 * Restores the Windows taskbar to its visible state.
	 */
	public static function restoreTaskbar():Void
	{
		WindowData.restoreTaskbar();
	}

	/**
	 * Hides all open windows.
	 */
	public static function hideWindows():Void
	{
		WindowData.hideWindows();
	}

	/**
	 * Restores all previously hidden windows.
	 */
	public static function restoreWindows():Void
	{
		WindowData.restoreWindows();
	}

	/**
	 * Removes the icon from the window.
	 */
	public static function removeWindowIcon():Void
	{
		WindowData.removeWindowIcon();
	}

	/**
	 * Enables support for high DPI displays.
	 */
	public static function allowHighDPI():Void
	{
		WindowData.registerHighDpi();
	}
}

#if cpp
@:headerCode('
    #include <windows.h>
    #include <iostream>
    #include <string>
    #include <hxcpp.h>
')

/**
 * Provides static methods for setting and restoring the user's desktop wallpaper on Windows.
 */
class Wallpaper
{
	/**
	 * Stores the path to the previous wallpaper, if available.
	 */
	@:noCompletion
	public static var oldWallpaper(default, null):String;

	/**
	 * Sets the oldWallpaper variable to the current wallpaper path.
	 */
	@:noCompletion
	public static function setOld():Void
	{
		oldWallpaper = _setOld();
	}

	/**
	 * Sets the user's desktop wallpaper to the specified path.
	 * @param path The file path to the wallpaper image.
	 */
	// spellchecker: disable
	@:functionCode('
		wchar_t* wallpath = const_cast<wchar_t*>(path.wchar_str());
		SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, reinterpret_cast<void*>(wallpath), SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
	')
	// spellchecker: enable
	@:noCompletion
	public static function setWallpaper(path:String):Void
		return;

	/**
	 * Retrieves the current wallpaper path and returns it as a String.
	 * @return The current wallpaper file path.
	 */
	// spellchecker: disable
	@:functionCode('
		WCHAR buffer[1024] = {0};
		SystemParametersInfoW(SPI_GETDESKWALLPAPER, 256, &buffer, NULL);
		return String(buffer);
	')
	// spellchecker: enable
	@:noCompletion
	private static function _setOld():String
		return "";
}
#end
