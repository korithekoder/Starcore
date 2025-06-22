package starcore.debug.editors;

import flixel.FlxSprite;
import starcore.debug.objects.EntityPartBanner;
import flixel.FlxG;
import flixel.util.FlxColor;
import lime.app.Event;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import openfl.utils.Assets;
import starcore.backend.data.Constants;
import starcore.backend.util.AssetUtil;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;
import starcore.ui.UIClickableText;

using StringTools;

/**
 * Type definition that's a "template" for entity JSON
 * data. This holds basic information about an entity, such as
 * its name, attributes for how much health it has, how much damage it does,
 * what type of planets it can spawn on, etc.
 * 
 * NOTE: The ID is accessed from the file name when it is being accessed and extracted.
 */
typedef EntityData =
{
	/**
	 * The display name of the entity.
	 * This is the name that the user will see in-game.
	 */
	var name:String;

	/**
	 * The body parts that make up a complex entity.
	 */
	var parts:Array<EntityPartData>;

	/**
	 * The way the entity is described in the game.
	 * If it is `null`, then the default description will be used.
	 */
	@:optional var description:String;
}

/**
 * Type definition for the data of an entity body part.
 */
typedef EntityPartData =
{
	/**
	 * The ID of the body part.
	 */
	var id:String;

	/**
	 * How large the body part is.
	 * If set to 2, then it will be 2x as large, 4 for 4x as large, etc.
	 */
	var scale:Float;

	/**
	 * How far off the body part is from the center of the entity
	 * on the X axis.
	 */
	var offsetX:Int;

	/**
	 * How far off the body part is from the center of the entity
	 * on the Y axis.
	 */
	var offsetY:Int;
}

/**
 * The debug editor for creating new entities. This is where you
 * define the name of the entity, its body parts, how big each body
 * part is, etc.
 */
class EntityCreationEditorState extends DebugEditorState
{
	var loadSpriteSheetButton:UIClickableText;

	// NOTE: The current path variable doesn't have an extension
	// at the end of it for the sake of flexibility
	var currentLoadedPath:String = '';

	var currentEntityData:EntityData = {
		name: 'New Entity',
		parts: []
	};

	var bodyPartDisplay:FlxSprite;

	var test:EntityPartBanner;

	//
	// METHOD OVERRIDES
	// =========================================

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		test.entitySpriteSheetPaths = ['$currentLoadedPath.png', '$currentLoadedPath.xml'];
	}

	function createStage():Void
	{
		test = new EntityPartBanner({x: 100, y: 300});
		add(test);

		// bodyPartDisplay = new FlxSprite();
		// bodyPartDisplay.loadGraphic(Constants.UNKNOWN_ENTITY_TEXTURE_PATH);
		// bodyPartDisplay.scale.set(scale, scale);
		// bodyPartDisplay.updateHitbox();
		// bodyPartDisplay.setPosition(bg.x - 8 - bodyPartDisplay.width * scale, bg.y + bg.height / 2 - bodyPartDisplay.height * scale / 2);
	}

	function createUI():Void
	{
		setupButtons();
	}

	//
	// SETUP FUNCTIONS
	// ================================

	function setupButtons():Void
	{
		loadSpriteSheetButton = new UIClickableText();
		loadSpriteSheetButton.text = 'Load Sprite Sheet';
		loadSpriteSheetButton.size = 32;
		loadSpriteSheetButton.font = Constants.DEBUG_EDITOR_FONT;
		loadSpriteSheetButton.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		loadSpriteSheetButton.updateHitbox();
		loadSpriteSheetButton.setPosition(10, 50);
		loadSpriteSheetButton.behavior.displayHoverCursor = true;
		loadSpriteSheetButton.behavior.onClick = openSpriteSheet;
		loadSpriteSheetButton.behavior.onHover = () ->
		{
			FlxG.sound.play(PathUtil.ofSharedSound('blip'));
		};
		add(loadSpriteSheetButton);
	}

	//
	// EXTRA FUNCTIONS
	// ================================

	function openSpriteSheet():Void
	{
		LoggerUtil.log('Attempting to open a sprite sheet');
		var dialog:FileDialog = new FileDialog();
		var onSelectEvent:Event<String->Void> = new Event<String->Void>();
		onSelectEvent.add((path:String) ->
		{
			// Modify the path passed down and replace all
			// back slashes (\) with slashes (/)
			var p:String = path.replace('\\', '/');
			LoggerUtil.log('File Opened -> $p', false);

			// Convert the chosen entity's pathways into a
			// pathway that HaxeFlixel can accept (in the assets folder)
			LoggerUtil.log('Converting pathway into path to game entity textures folder');
			var assetsDir:String = 'assets/entities/textures/';
			var fileName:String = AssetUtil.removeFileExtension(p.split('/').pop());
			currentLoadedPath = '$assetsDir$fileName';
			var destPathPng:String = '$currentLoadedPath.png';
			var destPathXml:String = '$currentLoadedPath.xml';
			LoggerUtil.log('Path "$p" was converted to "$destPathPng"', false);
			LoggerUtil.log('Path "$p" was converted to "$destPathXml"', false);

			// Log and check if the .png asset is valid
			if (Assets.exists(destPathPng))
			{
				LoggerUtil.log('Entity spritesheet "$destPathPng" was successfully loaded.', false);
			}
			else
			{
				LoggerUtil.log('Entity spritesheet "$destPathPng" is not cached! Add the entity\'s .png file in '
					+ '"assets/entities/textures/" to properly load the entity\'s spritesheet.',
					WARNING, false);
			}

			// Log and check if the .xml asset is valid
			if (Assets.exists(destPathXml))
			{
				LoggerUtil.log('Entity format "$destPathXml" was successfully loaded.', false);
			}
			else
			{
				LoggerUtil.log('Entity format "$destPathXml" is not cached! Add the entity\'s .xml file in '
					+ '"assets/entities/textures/" to properly load the entity\'s format.',
					WARNING, false);
			}
		});
		dialog.onSelect = onSelectEvent;
		dialog.browse(FileDialogType.OPEN, 'png', null, 'Open a sprite sheet');
	}
}
