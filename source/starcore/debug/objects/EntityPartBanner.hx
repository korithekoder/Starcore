package starcore.debug.objects;

import flixel.FlxSprite;
import starcore.ui.UIClickableSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import starcore.backend.data.Constants;
import starcore.ui.UITextBox;

/**
 * Options for a new entity part banner object.
 */
typedef EntityPartBannerOptions =
{
	/**
	 * The x position of the banner.
	 */
	var x:Float;

	/**
	 * The y position of the banner.
	 */
	var y:Float;

	/**
	 * The scale of the banner.
	 * If `null` is assigned, then it defaults to 1.
	 */
	@:optional var scale:Int;
}

/**
 * Debug object for showing a banner of info on an entity part.
 * This is only used in the entity creation editor.
 */
class EntityPartBanner extends FlxSpriteGroup
{
	//
	// DISPLAY OBJECTS
	// ==================================

	/**
	 * The background, what else?
	 */
	public var bg:UIClickableSprite;

	var outlineBg:FlxSprite;

	var idTextbox:UITextBox;

	//
	// DATA
	// =====================

	/**
	 * The ID of the body part.
	 */
	public var id(get, null):String;

	/**
	 * Is this entity part banner focused?
	 */
	public var isFocused:Bool = false;

	/**
	 * @param options The options for the new entity part banner. 
	 */
	public function new(options:EntityPartBannerOptions)
	{
		super();

		var scale:Int = (options.scale != null) ? options.scale : 1;

		bg = new UIClickableSprite();
		bg.makeGraphic(300, 100, FlxColor.fromRGB(220, 220, 220));
		bg.scale.set(scale, scale);
		bg.updateHitbox();
		bg.setPosition(options.x, options.y);
		bg.behavior.displayHoverCursor = false;
		bg.behavior.onClick = () -> {
			isFocused = true;
		};
		bg.behavior.onUnclick = () -> {
			trace('bing bong');
		}
		add(bg);

		idTextbox = new UITextBox(bg.x + 8, bg.y + 3, 100, 16, Constants.DEBUG_EDITOR_FONT, 'ex: head');
		idTextbox.inputTextObject.filterMode = FlxInputTextFilterMode.CHARS(Constants.VALID_ITEM_ENTITY_NAME_CHARACTERS);
		idTextbox.scale.set(scale, scale);
		idTextbox.inputTextObject.onTextChange.add((text:String, _) ->
		{
			id = text;
		});
		add(idTextbox);
	}

	//
	// GETTERS AND SETTERS
	// =======================================

	@:noCompletion
	function get_id():String
	{
		return idTextbox.getValue('');
	}
}
