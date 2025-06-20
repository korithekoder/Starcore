package starcore.debug.objects;

import starcore.backend.data.Constants;
import starcore.ui.UITextBox;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

/**
 * Options for a new entity part banner object.
 */
typedef EntityPartBannerOptions =
{
	var x:Float;
	var y:Float;

	@:optional var scale:Int;
}

/**
 * Debug object for showing a banner of info on an entity part.
 */
class EntityPartBanner extends FlxSpriteGroup
{
	//
	// DISPLAY OBJECTS
	// ==================================

	/**
	 * The background, what else?
	 */
	public var bg:FlxSprite;

	var idTextbox:UITextBox;

	//
	// DATA
	// =====================

	/**
	 * The ID of the body part.
	 */
	public var id(get, null):String;

	/**
	 * The pathways to the sprite sheet `.png` and `.xml` to obtain body part textures from.
	 * 
	 * First element is to the `.png` image file, second is to the `.xml` file.
	 */
	public var entitySpriteSheetPaths:Array<String> = [];

	/**
	 * @param options The options for the new entity part banner. 
	 */
	public function new(options:EntityPartBannerOptions)
	{
		super();

		var scale:Int = (options.scale != null) ? options.scale : 1;

		bg = new FlxSprite();
		bg.makeGraphic(300, 100, FlxColor.fromRGB(220, 220, 220));
		bg.scale.set(scale, scale);
		bg.updateHitbox();
		bg.setPosition(options.x, options.y);
		add(bg);

		idTextbox = new UITextBox(bg.x + 8, bg.y + 3, 100, 16, null, 'ex: head');
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
