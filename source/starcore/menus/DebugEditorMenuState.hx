package starcore.menus;

import starcore.backend.util.LoggerUtil;
import starcore.backend.util.FlixelUtil;
import starcore.debug.editors.EntityCreationEditorState;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import starcore.backend.Controls;
import starcore.backend.data.ClientPrefs;
import starcore.backend.data.Constants;
import starcore.backend.util.CacheUtil;

/**
 * The state where all the different editors can be accessed from.
 */
class DebugEditorMenuState extends FlxState
{
	var titleText:FlxText;
	var infoText:FlxText;

	override function create():Void
	{
		super.create();

		CacheUtil.canPlayMenuMusic = true;

		// Set the editor menu background
		FlxG.camera.bgColor = Constants.DEBUG_EDITOR_BACKGROUND_COLOR;

		// Enable only the Scanline shader, since all the others
		// would most likely mess with development
		var shaderMode:ShaderModeType = ClientPrefs.getOption('shaderMode');
		if (ClientPrefs.getOption('editorFilters'))
		{
			if (shaderMode == ShaderModeType.DEFAULT || shaderMode == ShaderModeType.FAST)
			{
				FlixelUtil.setFilters(ShaderModeType.MINIMAL);
			}
			else
			{
				// This means the user has either MINIMAL or NONE enabled, so
				// we can just leave it be and move on since it won't mess with development
				// inside of the editors!
			}
		}

		var uiBackBind:String = ClientPrefs.getBind('ui_back').toString();
		infoText = new FlxText();
		infoText.text = 'This is where you, the developer, can access multiple editors to
			accomplish various tasks that otherwise would be difficult to do manually.
			
			1: Entity Creation Editor
			$uiBackBind: Back to Game';
		infoText.font = Constants.DEBUG_EDITOR_FONT;
		infoText.size = 20;
		infoText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		infoText.alignment = CENTER;
		infoText.updateHitbox();
		infoText.screenCenter(XY);
		add(infoText);

		titleText = new FlxText();
		titleText.text = 'Welcome to the Debug Editor Menu';
		titleText.font = Constants.DEBUG_EDITOR_FONT;
		titleText.size = 48;
		titleText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		titleText.updateHitbox();
		titleText.x = (FlxG.width / 2) - (titleText.width / 2);
		titleText.y = (infoText.y - titleText.height) - 50;
		add(titleText);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ONE)
		{
			FlxG.switchState(() -> new EntityCreationEditorState('Entity Creation', Constants.ENTITY_CREATION_EDITOR_VERSION));
		}

		if (Controls.getBinds().UI_BACK_JUST_PRESSED)
		{
			// Switch back the shaders, since we're going
			// back into the main game
			LoggerUtil.log('Switching back to the base game');
			FlixelUtil.setFilters(ClientPrefs.getOption('shaderMode'));
			FlxG.switchState(() -> new MainMenuState());
		}
	}
}
