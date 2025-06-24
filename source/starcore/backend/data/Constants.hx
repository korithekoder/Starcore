package starcore.backend.data;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import starcore.backend.util.PathUtil;

/**
 * Class that holds all of the general values that do not change.
 */
final class Constants
{
	//
	// SAVE BIND ID'S
	// ======================================

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

	//
	// VERSIONS
	// ============================================

	/**
	 * The version of the entity creation editor.
	 */
	public static final ENTITY_CREATION_EDITOR_VERSION:String = '0.1.0-PROTOTYPE';

	//
	// DEBUG
	// ========================================

	/**
	 * The pathway to the font for all debug editors.
	 */
	public static final DEBUG_EDITOR_FONT:String = PathUtil.ofFont('vcr');

	/**
	 * Name of the music that plays when in the editors.
	 */
	public static final DEBUG_EDITOR_MUSIC_NAME:String = '2 Sided';

	/**
	 * The default color for any debug editor extending to `starcore.debug.DebugEditorState`.
	 */
	public static final DEBUG_EDITOR_BACKGROUND_COLOR:FlxColor = FlxColor.fromRGB(210, 210, 210);

	/**
	 * Pathway to the image that's used in place for a missing texture.
	 */
	public static final UNKNOWN_TEXTURE_PATH:String = PathUtil.ofSharedImage('debug/unknown_texture');

	//
	// LOGGING
	// =======================================

	/**
	 * The maximum amount of log files that can be stored in the `logs` folder.
	 */
	public static final MAX_LOG_FILES_LIMIT:Int = 30;

	//
	// MUSIC & SOUNDS
	// =====================================================

	/**
	 * Name of the music that plays when in the main menus.
	 */
	public static final MENU_MUSIC_NAME:String = 'Stargazer';

	/**
	 * The maximum amount of reverb sound effects that can be played at once.
	 */
	public static final REVERB_SOUND_EFFECT_LIMIT:Int = 15;

	//
	// BACKGROUND
	// ================================

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
	 * How much the background camera of the play state scrolls when the mouse moves.
	 */
	public static final BACKGROUND_CAMERA_SCROLL_MULTIPLIER:Float = 0.025;

	//
	// ITEMS & ENTITIES
	// =========================================================

	/**
	 * A `String` that holds characters which are valid for
	 * creating names for entities and items.
	 */
	public static final VALID_ITEM_ENTITY_NAME_CHARACTERS:String = 'abcdefghijklmnopqrstuvwxyz_';

	/**
	 * The default description for any entity if the description for it is `null` or empty.
	 */
	public static final DEFAULT_ENTITY_DESCRIPTION:String = 'This one doesn\'t seem to have a description...';

	//
	// WORLD
	// =================================================

	/**
	 * How wide in pixels a tile is. This is used for the world tilemap.
	 */
	public static final TILE_WIDTH:Int = 16;

	/**
	 * How height in pixels a tile is. This is used for the world tilemap.
	 */
	public static final TILE_HEIGHT:Int = 16;

	/**
	 * How much the gameplay camera of the play state scrolls when the mouse moves.
	 */
	public static final WORLD_CAMERA_SCROLL_MULTIPLIER:Float = 0.125;

	//
	// UI
	// =============================================

	/**
	 * The allowed alphabetic characters that can be added to text in a
	 * `starcore.ui.TextBox` object.
	 */
	public static final ALLOWED_TEXT_BOX_ALPHABET_CHARACTERS:Array<FlxKey> = [
		A,
		B,
		C,
		D,
		E,
		F,
		G,
		H,
		I,
		J,
		K,
		L,
		M,
		N,
		O,
		P,
		Q,
		R,
		S,
		T,
		U,
		V,
		W,
		X,
		Y,
		Z,
		ONE,
		TWO,
		THREE,
		FOUR,
		FIVE,
		SIX,
		SEVEN,
		EIGHT,
		NINE,
		ZERO,
		GRAVEACCENT,
		MINUS,
		PLUS,
		LBRACKET,
		RBRACKET,
		BACKSLASH,
		SEMICOLON,
		QUOTE,
		COMMA,
		PERIOD,
		SLASH,
		NUMPADZERO,
		NUMPADONE,
		NUMPADTWO,
		NUMPADTHREE,
		NUMPADFOUR,
		NUMPADFIVE,
		NUMPADSIX,
		NUMPADSEVEN,
		NUMPADEIGHT,
		NUMPADNINE,
		NUMPADMINUS,
		NUMPADPLUS,
		NUMPADPERIOD,
		NUMPADMULTIPLY,
		NUMPADSLASH
	];

	/**
	 * The allowed floating point number characters that can be added to text in a
	 * `starcore.ui.TextBox` object.
	 */
	public static final ALLOWED_TEXT_BOX_FLOAT_CHARACTERS:Array<FlxKey> = [
		ONE,
		TWO,
		THREE,
		FOUR,
		FIVE,
		SIX,
		SEVEN,
		EIGHT,
		NINE,
		ZERO,
		PERIOD,
		NUMPADZERO,
		NUMPADONE,
		NUMPADTWO,
		NUMPADTHREE,
		NUMPADFOUR,
		NUMPADFIVE,
		NUMPADSIX,
		NUMPADSEVEN,
		NUMPADEIGHT,
		NUMPADNINE,
		NUMPADPERIOD
	];

	/**
	 * The allowed integer characters that can be added to text in a
	 * `starcore.ui.TextBox` object.
	 */
	public static final ALLOWED_TEXT_BOX_INT_CHARACTERS:Array<FlxKey> = [
		ONE,
		TWO,
		THREE,
		FOUR,
		FIVE,
		SIX,
		SEVEN,
		EIGHT,
		NINE,
		ZERO,
		NUMPADZERO,
		NUMPADONE,
		NUMPADTWO,
		NUMPADTHREE,
		NUMPADFOUR,
		NUMPADFIVE,
		NUMPADSIX,
		NUMPADSEVEN,
		NUMPADEIGHT,
		NUMPADNINE
	];

	//
	// API
	// =============================

	/**
	 * The ID for the app on Discord to display in the user's
	 * "Activity" box, showing that they are playing Starcore and
	 * for displaying how long they have played it.
	 */
	public static final DISCORD_APP_ID:String = '1361513332883980309';

	function new() {}
}
