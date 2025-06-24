package starcore.debug.editors;

import flixel.tweens.FlxTween;
import starcore.backend.util.DataUtil;
import starcore.ui.UIClickableSprite;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import lime.app.Event;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import openfl.utils.Assets;
import starcore.backend.data.Constants;
import starcore.backend.util.AssetUtil;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;
import starcore.debug.objects.EntityPartBanner;
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
	// 0 = .png file, 1 = .xml file
	var entitySpriteSheetPaths:Array<String> = [];

	var currentEntityData:EntityData = {
		name: 'New Entity',
		parts: []
	};

	var bodyPartDisplay:FlxSprite;
	var bodyPartBanners:FlxSpriteGroup;

	var addRemoveButtons:FlxSpriteGroup;

	//
	// METHOD OVERRIDES
	// =========================================

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		entitySpriteSheetPaths = ['$currentLoadedPath.png', '$currentLoadedPath.xml'];

		setBodyPartDisplay();
	}

	function createStage():Void
	{
		bodyPartBanners = new FlxSpriteGroup();
		add(bodyPartBanners);

		addRemoveButtons = new FlxSpriteGroup();
		add(addRemoveButtons);

		var addButton:UIClickableSprite = new UIClickableSprite();
		addButton.loadGraphic(PathUtil.ofSharedImage('ui/add'));
		addButton.scale.set(3, 3);
		addButton.updateHitbox();
		addButton.setPosition(40, 110);
		addButton.behavior.hoverSound = PathUtil.ofSharedSound('blip');
		addButton.behavior.clickSound = PathUtil.ofSharedSound('click');
		addButton.behavior.onClick = () -> {
			addBodyPartBanner();
		};
		addButton.behavior.resetCursorOnClick = false;
		addRemoveButtons.add(addButton);

		var removeButton:UIClickableSprite = new UIClickableSprite();
		removeButton.loadGraphic(PathUtil.ofSharedImage('ui/remove'));
		removeButton.scale.set(3, 3);
		removeButton.updateHitbox();
		removeButton.setPosition(40, addButton.y + addButton.height + 15);
		removeButton.behavior.hoverSound = PathUtil.ofSharedSound('blip');
		removeButton.behavior.onClick = () -> {
			if (bodyPartBanners.length > 0)
			{
				bodyPartBanners.remove(bodyPartBanners.members[bodyPartBanners.length - 1], true);
				FlxG.sound.play(PathUtil.ofSharedSound('click')); // Plays sound here instead in case there isn't any banners left
			}
			else
			{
				FlxTween.shake(removeButton, 0.08, 0.05);
				FlxG.sound.play(PathUtil.ofSharedSound('nope'));
			}
		}
		removeButton.behavior.resetCursorOnClick = false;
		addRemoveButtons.add(removeButton);

		bodyPartDisplay = new FlxSprite();
		bodyPartDisplay.loadGraphic(Constants.UNKNOWN_TEXTURE_PATH);
		updateBodyPartPos();
		add(bodyPartDisplay);
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

	//
	// UTILITY FUNCTIONS
	// ========================================

	function addBodyPartBanner():Void
	{
		// For correctly calculating the position of the new banner
		// based on the banner's height
		var lastBanner:EntityPartBanner = bodyPartBanners.members.length > 0 ? cast bodyPartBanners.members[bodyPartBanners.length - 1] : null;
		var newY:Float = (lastBanner != null) ? lastBanner.bg.height : 0;
		var banner:EntityPartBanner = new EntityPartBanner({x: 175, y: 300 + newY + (bodyPartBanners.length * 50)});
		bodyPartBanners.add(banner);
	}

	function setBodyPartDisplay():Void
	{
		if (entitySpriteSheetPaths.length < 2)
		{
			return;
		}

		if (Assets.exists(entitySpriteSheetPaths[0]) && Assets.exists(entitySpriteSheetPaths[1]))
		{
			bodyPartDisplay.loadGraphic(entitySpriteSheetPaths[0], true);
			bodyPartDisplay.frames = FlxAtlasFrames.fromSparrow(entitySpriteSheetPaths[0], entitySpriteSheetPaths[1]);
			// bodyPartDisplay.animation.addByIndices('icon', '${test.id}_', [0], '', 0, false);
			bodyPartDisplay.animation.play('icon');
			updateBodyPartPos();
		}
		else
		{
			bodyPartDisplay.loadGraphic(Constants.UNKNOWN_TEXTURE_PATH);
			updateBodyPartPos();
		}
	}

	function updateBodyPartPos():Void
	{
		bodyPartDisplay.scale.set(4, 4);
		bodyPartDisplay.updateHitbox();
		bodyPartDisplay.setPosition((FlxG.width - bodyPartDisplay.width) - 50, (FlxG.height / 2) - (bodyPartDisplay.height / 2));
	}
}
