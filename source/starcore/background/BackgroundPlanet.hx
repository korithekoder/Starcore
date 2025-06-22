package starcore.background;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import starcore.backend.data.Constants;
import starcore.backend.util.PathUtil;

/**
 * Represents a background planet in the game.
 */
class BackgroundPlanet extends FlxSprite
{
	public function new()
	{
		super();
		var newScale:Float = FlxG.random.float(4, 7);
		loadGraphic(PathUtil.ofSharedImage('bg/bg_planet_${FlxG.random.int(1, 2)}'));
		scale.set(newScale, newScale);
		updateHitbox();
		setPosition(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height));
		FlxSpriteUtil.setBrightness(this, (newScale / 8.2) * -1);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		x += Constants.BACKGROUND_PLANET_SCROLL_SPEED;
		if (x > FlxG.width)
		{
			x = 0 - width;
		}
	}
}
