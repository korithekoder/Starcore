package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.tweens.FlxTween;
import lime.app.Application;
import openfl.Lib;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import starcore.backend.api.DiscordClient;
import starcore.backend.data.ClientPrefs;
import starcore.backend.util.CacheUtil;
import starcore.backend.util.FlixelUtil;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;
import starcore.menus.MainMenuState;
import starcore.shaders.*;
#if web
import js.Browser;
#end
#if (web && debug)
import openfl.events.KeyboardEvent;
import starcore.backend.util.SaveUtil;
#end

/**
 * The initial state of the game. This is where
 * you can load assets and set up the game.
 */
class InitState extends FlxState
{
	override public function create():Void
	{
		// Setup the logger for Starcore
		LoggerUtil.initialize();

		// Log that we are setting up Starcore
		LoggerUtil.log('INITIALIZING STARCORE SETUP', false);

		// Load all of the player's settings and options.
		// Note that if this line is not present, it will
		// cause null errors and crash the game!
		ClientPrefs.loadAll();

		// TODO: Add a small loading screen here!

		// Assign and configure Flixel settings
		configureFlixelSettings();

		// Add the processes that always run in the background
		addBackgroundProcesses();

		// Add the event listeners
		addEventListeners();

		// Register all of the entities that are in the game
		registerEntities();

		// Start up Discord rich presence
		DiscordClient.initialize();

		// Log that everything is done setting up
		LoggerUtil.log('STARCORE SETUP COMPLETE', false);

		// Switch to the main menu state after everything has loaded
		FlxG.switchState(() -> new MainMenuState());
	}

	function configureFlixelSettings():Void
	{
		// Log info
		LoggerUtil.log('Configuring Flixel settings');

		// Set the cursor to be the system default
		FlxG.mouse.useSystemCursor = true;

		// Set auto pause to false
		FlxG.autoPause = false;

		// Set the stage and scaling modes
		Lib.current.stage.align = 'tl';
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		// Disable the binds for increasing/decreasing/muting
		// the flixel master volume
		FlxG.sound.volumeUpKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.muteKeys = [];

		// Set the default font
		FlxAssets.FONT_DEFAULT = PathUtil.ofFont('Born2bSportyFS');

		// Set the default sound extension based on the target platform
		FlxAssets.defaultSoundExtension = #if web 'mp3' #else 'ogg' #end;

		// Set the stage quality
		#if !web
		FlxG.stage.quality = StageQuality.LOW;
		#else
		FlxG.stage.quality = StageQuality.MEDIUM;
		#end

		// Make the window borderless when it is
		// not in fullscreen mode
		// TODO: Figure out how to make it draggable?
		#if desktop
		Application.current.window.borderless = true;
		#end

		// Disable the right-click context menu for HTML5
		#if html5
		Browser.document.addEventListener('contextmenu', (e) ->
		{
			e.preventDefault();
		});
		#end

		// Assign the shaders AFTER all assets have been loaded!
		#if ADVANCED_SHADERS_ALLOWED
		CacheUtil.vcrBorderShader = new VCRBorderShader();
		CacheUtil.vcrMario85Shader = new VCRMario85Shader();
		#end
		CacheUtil.grainShader = new GrainShader();

		// Set the shaders based on the user's options
		FlixelUtil.setFilters(ClientPrefs.getOption('shaderMode'));

		// Configure the event listener for detecting caps lock
		// if the target is set to HTML5
		#if html5
		untyped __js__('
			window.__haxe_capslock__ = false;
			document.addEventListener("keydown", function (e) {
				if (e.getModifierState) {
					window.__haxe_capslock__ = e.getModifierState("CapsLock");
				}
			});
		');
		#end
	}

	function addBackgroundProcesses():Void
	{
		// Log info
		LoggerUtil.log('Adding background processes');
		// Update the shaders that need to
		// constantly be reset
		FlxG.signals.postUpdate.add(() ->
		{
			#if ADVANCED_SHADERS_ALLOWED
			CacheUtil.vcrMario85Shader.update(FlxG.elapsed);
			#end
			CacheUtil.grainShader.update(FlxG.elapsed);
		});
	}

	function addEventListeners():Void
	{
		// Log info
		LoggerUtil.log('Adding event listeners');

		#if desktop
		// Maximize/Minimize volume when the window is gets/loses focus
		Application.current.window.onFocusIn.add(() ->
		{
			// Bring the volume back up when the window is focused again
			if (ClientPrefs.getOption('minimizeVolume') && !CacheUtil.isWindowFocused)
			{
				// Set back to one decimal place (0.1) when the screen gains focus again
				// (note that if the user had the volume all the way down, it will be set to zero)
				FlxG.sound.volume = (!(Math.abs(FlxG.sound.volume) < FlxMath.EPSILON)) ? 0.1 : 0;
				CacheUtil.isWindowFocused = true;
				// Set the volume back to the last volume used
				FlxTween.num(FlxG.sound.volume, CacheUtil.lastVolumeUsed, 0.3, {type: FlxTweenType.ONESHOT}, (v:Float) ->
				{
					FlxG.sound.volume = v;
				});
			}
		});
		Application.current.window.onFocusOut.add(() ->
		{
			// Minimize the volume when the window loses focus
			if (ClientPrefs.getOption('minimizeVolume') && CacheUtil.isWindowFocused)
			{
				// Set the last volume used to the current volume
				CacheUtil.lastVolumeUsed = FlxG.sound.volume;
				CacheUtil.isWindowFocused = false;
				// Tween the volume to 0.05
				FlxTween.num(FlxG.sound.volume, (!(Math.abs(FlxG.sound.volume) < FlxMath.EPSILON)) ? 0.05 : 0, 0.3, {type: FlxTweenType.ONESHOT}, (v:Float) ->
				{
					FlxG.sound.volume = v;
				});
			}
		});
		#end

		// Delete all save data if CTRL + BACKSPACE
		// is pressed on debug mode in the web version
		#if (web && debug)
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (_) ->
		{
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.BACKSPACE)
			{
				SaveUtil.deleteAll();
			}
		});
		#end

		// Do shit like saving the user's data when the game closes
		Application.current.window.onClose.add(() ->
		{
			FlixelUtil.closeGame(false);
		});
	}

	function registerEntities():Void {}
}
