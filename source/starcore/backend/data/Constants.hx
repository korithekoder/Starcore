package starcore.backend.data;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import starcore.backend.util.PathUtil;

/**
 * Class that holds all of the general values that do not change.
 */
final class Constants {

	/**
	 * DEFAULTS
	 * ======================
	 */
	/**
	 * The default controls for the player. This is typically used when
	 * the player wishes to reset all of their binds.
	 */
	public static final DEFAULT_CONTROLS_KEYBOARD:Map<String, FlxKey> = [
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
		'ms_openeditors' => F7
	];

	/**
	 * The default options for the game. These are only really used when
     * the player either updated the game ***OR*** is missing anything important.
	 */
	public static final DEFAULT_OPTIONS:Map<String, Any> = [
		// Misc.
		'discordRPC' => true,
		'minimizeVolume' => true,
		// Debug
		'editorFilters' => true
	];

	/**
	 * SAVE BIND ID'S
	 * ==========================
	 */
	/**
	 * The name of the save file for the player's options.
	 */
	public static final OPTIONS_SAVE_BIND_ID:String = 'options';

	/**
	 * The name of the save file for the player's controls.
	 */
	public static final CONTROLS_SAVE_BIND_ID:String = 'controls';

	/**
	 * The name of the save file for the player's progress.
	 */
	public static final PROGRESS_SAVE_BIND_ID:String = 'progress';

	/**
	 * VERSIONS
	 * =================================
	 */
	/**
	 * The version of the entity creation editor.
	 */
	public static final ENTITY_CREATION_EDITOR_VERSION:String = '0.1.0-PROTOTYPE';

	/**
	 * DEBUG EDITORS
	 * ===================
	 */
	/**
	 * The pathway to the font for all debug editors.
	 */
	public static final DEBUG_EDITOR_FONT:String = PathUtil.ofFont('vcr');

	/**
	 * Name of the music that plays when in the editors.
	 */
	public static final DEBUG_EDITOR_MUSIC_NAME:String = '2 Sided';

	/**
	 * The default color for any debug editor extending to `objects.states.DebugEditorState`.
	 */
	public static final DEBUG_EDITOR_BACKGROUND_COLOR:FlxColor = FlxColor.fromRGB(210, 210, 210);

	/**
	 * MUSIC
	 * ========================
	 */
	/**
	 * Name of the music that plays when in the main menus.
	 */
	public static final MENU_MUSIC_NAME:String = 'Stargazer';

	/**
	 * The maximum amount of reverb sound effects that can be played at once.
	 */
	public static final REVERB_SOUND_EFFECT_LIMIT:Int = 15;

	/**
	 * How fast background stars scroll in the distance.
	 */
	public static final BACKGROUND_STAR_SCROLL_SPEED:Float = 0.7;

	/**
	 * How fast background planets scroll in the distance.
	 */
	public static final BACKGROUND_PLANET_SCROLL_SPEED:Float = 0.3;

	/**
	 * How long it takes in seconds until the stars change their alpha value.
	 */
	public static final STAR_CHANGE_ALPHA_DELAY:Float = 2;

	/**
	 * A regular expression that holds characters which are valid for
	 * creating names for entities and items.
	 */
	public static final VALID_ITEM_ENTITY_NAME_CHARACTERS:EReg = ~/[a-z_]/;

	/**
	 * How wide in pixels a tile is. This is used for the world tilemap.
	 */
	public static final TILE_WIDTH:Int = 16;

	/**
	 * How height in pixels a tile is. This is used for the world tilemap.
	 */
	public static final TILE_HEIGHT:Int = 16;

	/**
	 * How much the background camera of the play state scrolls when the mouse moves.
	 */
	public static final BACKGROUND_CAMERA_SCROLL_MULTIPLIER:Float = 0.025;

	/**
	 * How much the gameplay camera of the play state scrolls when the mouse moves.
	 */
	public static final WORLD_CAMERA_SCROLL_MULTIPLIER:Float = 0.125;

	private function new() {}
}
