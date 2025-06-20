package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;
import starcore.backend.util.PathUtil;

/**
 * What do you think?
 */
class GrayscaleShader extends FlxRuntimeShader
{
	/**
	 * The amount of grayscale to apply.
	 * 
	 * 0 = No grayscale, 1 = Full grayscale.
	 */
	public var amount(default, set):Float = 1;

	/**
	 * @param amount How gray the screen should be. 0 = No grayscale, 1 = Full grayscale.
	 */
	public function new(amount:Float = 1)
	{
		super(Assets.getText(PathUtil.ofFrag('grayscale')));
		setAmount(amount);
	}

	function setAmount(value:Float):Void
	{
		amount = value;
		setFloat("_amount", amount);
	}

	@:noCompletion
	function set_amount(value:Float):Float
	{
		setAmount(value);
		return value;
	}
}
