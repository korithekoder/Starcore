package starcore.menus;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import starcore.backend.Controls;
import starcore.backend.data.Constants;
import starcore.backend.util.FlixelUtil;
import starcore.backend.util.PathUtil;
import starcore.backend.util.WorldUtil;
import starcore.background.BackgroundPlanet;
import starcore.background.BackgroundStar;
import starcore.play.PlayState;
import starcore.ui.UIClickableSprite;
import starcore.ui.UITextBox;

/**
 * State that represents the main menu of the game.
 * This is where the player can start a new game, load a game, or quit the game.
 */
class MainMenuState extends FlxTransitionableState
{
	var logo:FlxText;

	var buttons:Array<String> = ['play', 'quit'];
	var buttonsGroup:FlxTypedGroup<FlxSprite>;
	var buttonClickFunctions:Map<String, Void->Void>;
	var buttonWasClicked:Bool = false;

	var stars:FlxTypedGroup<BackgroundStar>;
	var planets:FlxTypedGroup<BackgroundPlanet>;
	var starChangeAlphaTimer:FlxTimer;

	override function create():Void
	{
		super.create();

		// Play menu music
		FlixelUtil.playMenuMusic(0.5);

		// Add the planets in the background
		planets = WorldUtil.generatePlanets();
		add(planets);

		// Add the stars in the background
		stars = WorldUtil.generateStars();
		add(stars);

		// Setup the logo
		logo = new FlxText();
		logo.text = 'STARCORE';
		logo.size = 165;
		logo.color = FlxColor.WHITE;
		logo.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(50, 50, 50), 8);
		logo.updateHitbox();
		logo.setPosition((FlxG.width / 2) - (logo.width / 2), 0);
		add(logo);

		// Setup the main menu buttons
		buttonsGroup = new FlxTypedGroup<FlxSprite>();
		add(buttonsGroup);

		buttonClickFunctions = [
			'play' => () ->
			{
				FlxG.switchState(() -> new PlayState());
			},
			'quit' => () ->
			{
				FlixelUtil.closeGame();
			}
		];

		var newY:Float = 350; // Change this to the starting Y position for the menu buttons
		for (btn in buttons)
		{
			var coolSwaggerButton:UIClickableSprite = new UIClickableSprite();
			coolSwaggerButton.loadGraphic(PathUtil.ofSharedImage('menus/main/$btn-button'));
			coolSwaggerButton.scale.set(4, 4);
			coolSwaggerButton.updateHitbox();
			coolSwaggerButton.behavior.updateHoverBounds(coolSwaggerButton.x, coolSwaggerButton.y, coolSwaggerButton.width, coolSwaggerButton.height);
			coolSwaggerButton.setPosition(0, newY);
			coolSwaggerButton.behavior.onClick = buttonClickFunctions.get(btn);
			coolSwaggerButton.behavior.onHover = () ->
			{
				FlixelUtil.playSoundWithReverb(PathUtil.ofSharedSound('blip'), 1);
				FlxSpriteUtil.setBrightness(coolSwaggerButton, 0.3);
			};
			coolSwaggerButton.behavior.onHoverLost = () ->
			{
				if (!buttonWasClicked)
				{
					FlxSpriteUtil.setBrightness(coolSwaggerButton, 0);
				}
			};
			buttonsGroup.add(coolSwaggerButton);
			newY += coolSwaggerButton.height + 40;
		}

		// Slowly bring up the volume for the music
		// FlxTween.num(0, 1, 3, {type: FlxTweenType.ONESHOT}, (v) ->
		// {
		// 	FlxG.sound.music.volume = v;
		// });
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if DEBUG_EDITORS_ALLOWED
		if (Controls.getBinds().DB_OPENEDITORS_JUST_PRESSED)
		{
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(PathUtil.ofSharedMusic(Constants.DEBUG_EDITOR_MUSIC_NAME), 0.15);
			FlxG.switchState(() -> new DebugEditorMenuState());
		}
		#end

		if (Controls.getBinds().UI_BACK_JUST_PRESSED)
		{
			FlixelUtil.closeGame();
		}
	}
}
