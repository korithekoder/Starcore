package starcore.backend.data;

import starcore.backend.util.FlixelUtil;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;
import starcore.backend.util.SaveUtil;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

/**
 * The shader(s) to display.
 */
enum ShaderModeType
{
	/**
	 * All shaders are applied (excluding Scanline).
	 */
	DEFAULT;

	/**
	 * Grain, Scanline, Hq2x and Tiltshift shaders are applied.
	 */
	FAST;

	/**
	 * Grain and Hq2x shaders are applied.
	 */
	MINIMAL;

	/**
	 * No shaders are applied.
	 */
	NONE;
}

/**
 * Class that handles, modifies and stores the user's
 * options and settings.
 * 
 * When you are updating a setting, use `setOption()` to update a user's option(s)
 * or `setBind()` to change a bind.
 * 
 * Controls are saved in their own variable, *NOT* in `options`.
 * 
 * The way controls are created is with this structure: `'keybind_id' => FlxKey.YOUR_KEY`.
 * To create a control, go to or search for `DEFAULT_CONTROLS_KEYBOARD` and then add your controls accordingly.
 * 
 * To access controls, use `starcore.backend.Controls`. (**TIP**: Read `starcore.backend.Controls`'s
 * documentation for how to access if binds are pressed!)
 */
final class ClientPrefs
{
	/**
	 * The default controls for the player. This is typically used when
	 * the player wishes to reset all of their binds.
	 */
	static final DEFAULT_CONTROLS_KEYBOARD:Map<String, FlxKey> = [
		// Movement
		'mv_up' => W,
		'mv_left' => A,
		'mv_down' => S,
		'mv_right' => D,
		// UI
		'ui_left' => LEFT,
		'ui_down' => DOWN,
		'ui_up' => UP,
		'ui_right' => RIGHT,
		'ui_select' => ENTER,
		'ui_back' => ESCAPE,
		// Volume
		'vl_up' => PLUS,
		'vl_down' => MINUS,
		'vl_mute' => F12,
		// Misc.
		'ms_fullscreen' => F11,
		// Debug
		'db_openeditors' => F7
	];

	/**
	 * The default options for the game. These are only really used when
	 * the player either updated the game ***OR*** is missing anything important.
	 */
	static final DEFAULT_OPTIONS:Map<String, Any> = [
		// Graphics
		#if !web
		'shaderMode' => DEFAULT,
		#else
		'shaderMode' => FAST,
		#end
		// Misc.
		'discordRPC' => true,
		'minimizeVolume' => true,
		// Debug
		'editorFilters' => true
	];

	/**
	 * The options the user currently has set.
	 */
	static var options:Map<String, Any> = DEFAULT_OPTIONS;

	/**
	 * The keyboard controls the user currently has set.
	 */
	static var controlsKeyboard:Map<String, FlxKey>;

	function new() {}

	//
	// GETTERS AND SETTERS
	// =====================================

	/**
	 * Get and return the default keyboard controls for the user.
	 * 
	 * @return A `Map` of the default keyboard controls.
	 */
	public static inline function getDefaultControls():Map<String, FlxKey>
	{
		return DEFAULT_CONTROLS_KEYBOARD.copy();
	}

	/**
	 * Get and return the default options for the user.
	 * 
	 * @return A `Map` of the default options.
	 */
	public static inline function getDefaultOptions():Map<String, Any>
	{
		return DEFAULT_OPTIONS.copy();
	}

	/**
	 * Get and return a client bind by its ID.
	 * 
	 * @param bind The bind to get as a `String`.
	 * @return     The value of the said bind. If it does not exist, then an
	 * 			   exception is thrown.
	 */
	public static function getBind(bind:String):FlxKey
	{
		if (controlsKeyboard.exists(bind))
		{
			return controlsKeyboard.get(bind);
		}
		else
		{
			FlixelUtil.crashGame('Attempted to obtain non-existent bind "$bind".');
		}
		return FlxKey.NONE;
	}

	/**
	 * Get and return all the user's currently set controls and binds.
	 * 
	 * @return A `Map` of all the user's binds.
	 */
	public static inline function getBinds():Map<String, FlxKey>
	{
		return controlsKeyboard.copy();
	}

	/**
	 * Get and return a user's option by its ID.
	 * 
	 * @param option        The option to get as a `String`.
	 * @return              The value of the option.
	 * @exception Exception If the option does not exist.
	 */
	public static function getOption(option:String):Dynamic
	{
		if (options.exists(option))
		{
			return options.get(option);
		}
		else
		{
			FlixelUtil.crashGame('Client option "$option" doesn\'t exist!');
		}
		return null;
	}

	/**
	 * Get and return all of the user's current options.
	 * 
	 * @return A `Map` of all of the user's options.
	 */
	public static inline function getOptions():Map<String, Any>
	{
		return options.copy();
	}

	/**
	 * Sets a client's option.
	 * 
	 * @param option      The setting to be set.
	 * @param value       The value to set the option to.
	 * @throws Exception  If the option does not exist.
	 */
	public static function setOption(option:String, value:Any):Void
	{
		if (options.exists(option))
		{
			options.set(option, value); // TODO: Figure out how to make this type-safe
			LoggerUtil.log('Set client option "$option" to "$value".', false);
			SaveUtil.saveUserOptions();
		}
		else
		{
			FlixelUtil.crashGame('Client option "$option" doesn\'t exist!');
		}
	}

	/**
	 * Set a specific key bind for the user.
	 * 
	 * @param bind        The bind to be set.
	 * @param newKey      The key to set it to.
	 * @throws Exception  If the bind does not exist.
	 */
	public static function setBind(bind:String, newKey:FlxKey):Void
	{
		if (controlsKeyboard.exists(bind))
		{
			controlsKeyboard.set(bind, newKey);
			SaveUtil.saveUserControls();
		}
		else
		{
			FlixelUtil.crashGame('Attempted to change non-existent bind "$bind".');
		}
	}

	//
	// METHODS
	// =============================

	/**
	 * Load and set all of the user's options and controls.
	 * 
	 * This function should only be called ONCE when the game is being initialized!
	 */
	public static function loadAll():Void
	{
		LoggerUtil.log('Loading all client preferences');

		var optionsData:FlxSave = new FlxSave();
		var controlsData:FlxSave = new FlxSave();

		optionsData.bind(Constants.OPTIONS_SAVE_BIND_ID, PathUtil.getSavePath());
		controlsData.bind(Constants.CONTROLS_SAVE_BIND_ID, PathUtil.getSavePath());

		if (optionsData.data.options != null)
		{
			options = optionsData.data.options;
		}
		else
		{
			options = getDefaultOptions();
			LoggerUtil.log('No options save data was found! Using default options', WARNING);
		}

		if (controlsData.data.keyboard != null)
		{
			controlsKeyboard = controlsData.data.keyboard;
		}
		else
		{
			controlsKeyboard = getDefaultControls();
			LoggerUtil.log('No controls save data was found! Using default controls', WARNING);
		}

		// Check if the user has any new options
		// (this is for when new options are added in an update!)
		for (option in DEFAULT_OPTIONS.keys())
		{
			if (!options.exists(option))
			{
				options.set(option, DEFAULT_OPTIONS.get(option));
			}
		}

		// Filter out any options that are not present in the current
		// standard set of options (which is determined by the default options)
		for (option in options.keys())
		{
			if (!DEFAULT_OPTIONS.exists(option))
			{
				options.remove(option);
			}
		}

		// Check if the user has any new controls
		// (this is for when new controls are added in an update!)
		for (bind in DEFAULT_CONTROLS_KEYBOARD.keys())
		{
			if (!controlsKeyboard.exists(bind))
			{
				controlsKeyboard.set(bind, DEFAULT_CONTROLS_KEYBOARD.get(bind));
				LoggerUtil.log('Added missing control "$bind" with default bind "${DEFAULT_CONTROLS_KEYBOARD.get(bind)}".', false);
			}
		}

		// Filter out any binds that are not present in the current
		// standard set of binds (which is determined by the default binds)
		for (bind in controlsKeyboard.keys())
		{
			if (!DEFAULT_CONTROLS_KEYBOARD.exists(bind))
			{
				controlsKeyboard.remove(bind);
				LoggerUtil.log('Removed unknown bind "$bind".', false);
			}
		}

		// Set the volume to the last used volume the user had
		if (optionsData.data.lastVolume != null)
		{
			FlxG.sound.volume = optionsData.data.lastVolume;
		}
		else
		{
			FlxG.sound.volume = 1.0;
		}

		// Respectfully close the saves to prevent data leaks
		optionsData.close();
		controlsData.close();
	}
}
