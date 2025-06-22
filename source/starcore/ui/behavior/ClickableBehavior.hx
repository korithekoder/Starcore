package starcore.ui.behavior;

import openfl.ui.MouseCursor;
import openfl.ui.Mouse;
import flixel.FlxG;

/**
 * Class for creating clickable-like behavior
 * for any `FlxObject` that uses it.
 */
class ClickableBehavior
{
	/**
	 * Called when `this` clickable object is clicked on.
	 */
	public var onClick:Void->Void = () -> {};

	/**
	 * Called when `this` clickable object gets clicked
	 * outside of its hover bounds while being focused.
	 */
	public var onUnclick:Void->Void = () -> {};

	/**
	 * Called when `this` clickable object is hovered on.
	 */
	public var onHover:Void->Void = () -> {};

	/**
	 * Called when `this` clickable object's hover boundaries are no longer overlapping
	 * the mouse.
	 */
	public var onHoverLost:Void->Void = () -> {};

	/**
	 * X bounds for the *left* side of `this` clickable object.
	 */
	public var bxl:Float;

	/**
	 * X bounds for the *right* side of `this` clickable object.
	 */
	public var bxr:Float;

	/**
	 * Y bounds for the *top* side of `this` clickable object.
	 */
	public var byt:Float;

	/**
	 * Y bounds for the *bottom* side of `this` clickable object.
	 */
	public var byb:Float;

	/**
	 * Is `this` current clickable object being hovered on?
	 */
	public var isHovered:Bool = false;

	/**
	 * Is the user allowed to click `this` object?
	 */
	public var canClick:Bool = true;

	/**
	 * The cursor that gets displayed (when whatever
	 * `FlxObject` has `this` behavior applied to it) is hovered over.
	 * 
	 * The attribute `displayHoverCursor` must be set to
	 * `true`, otherwise this will be ignored.
	 */
	public var hoverCursor:MouseCursor = MouseCursor.BUTTON;

	/**
	 * Is `this` clickable object focused?
	 */
	public var isFocused:Bool = false;

	/**
	 * Should `this` clickable object change to the
	 * set hover cursor when hovered over?
	 */
	public var displayHoverCursor:Bool = true;

	/**
	 * Should `this` clickable object reset back to
	 * `Mouse.ARROW` when it is clicked on?
	 */
	public var resetCursorOnClick:Bool = true;

	public function new() {}

	/**
	 * ...I don't think I have to explain this.
	 * 
	 * @param x      The X position of the object.
	 * @param y      The Y position of the object.
	 * @param width  The width of the object.
	 * @param height The height of the object.
	 */
	public function update(x:Float, y:Float, width:Float, height:Float):Void
	{
		if (isHoveringOverMouse())
		{
			if (!isHovered)
			{
				onHover();
				if (displayHoverCursor)
				{
					Mouse.cursor = hoverCursor;
				}
				isHovered = true;
			}

			if (FlxG.mouse.justPressed)
			{
				if (displayHoverCursor && resetCursorOnClick)
				{
					Mouse.cursor = MouseCursor.ARROW;
				}
				isFocused = true;
				onClick();
			}
		}
		else if (FlxG.mouse.justPressed && isFocused)
		{
			isFocused = false;
			onUnclick();
		}

		if (!isHoveringOverMouse() && isHovered)
		{
			isHovered = false;
			if (displayHoverCursor)
			{
				Mouse.cursor = MouseCursor.ARROW;
			}
			onHoverLost();
		}
	}

	/**
	 * Gets `this` clickable object's hover bounds as an array.
	 * @return The hover bounds as an array.
	 */
	public inline function getHoverBoundsArray():Array<Float>
	{
		return [bxl, bxr, byt, byb];
	}

	/**
	 * Sets the ***X*** hover bounds.
	 * 
	 * @param bxl Left X hover bound.
	 * @param bxr Right X hover bound.
	 */
	public function setHoverBoundsX(bxl:Float, bxr:Float):Void
	{
		this.bxl = bxl;
		this.bxr = bxr;
	}

	/**
	 * Sets the ***Y*** hover bounds.
	 * 
	 * @param byt Top Y hover bound.
	 * @param byb Bottom Y hover bound.
	 */
	public function setHoverBoundsY(byt:Float, byb:Float):Void
	{
		this.byt = byt;
		this.byb = byb;
	}

	/**
	 * Sets the hover bounds for all four sides of `this` clickable object. 
	 * 
	 * @param bxl Left X hover bound.
	 * @param bxr Right X hover bound.
	 * @param byt Top Y hover bound.
	 * @param byb Bottom Y hover bound.
	 */
	public function setHoverBounds(bxl:Float, bxr:Float, byt:Float, byb:Float):Void
	{
		this.bxl = bxl;
		this.bxr = bxr;
		this.byt = byt;
		this.byb = byb;
	}

	/**
	 * Reset the hover bounds to match `this` clickable object's hitbox.
	 * 
	 * @param x      The X position of the object.
	 * @param y      The Y position of the object.
	 * @param width  The width of the object.
	 * @param height The height of the object.
	 */
	public function updateHoverBounds(x:Float, y:Float, width:Float, height:Float):Void
	{
		bxl = x;
		bxr = x + width;
		byt = y;
		byb = y + height;
	}

	/**
	 * Is `this` clickable object's hover bounds overlapping the mouse?
	 * 
	 * @return If the mouse is inside `this` clickable object's hover bounds.
	 */
	public inline function isHoveringOverMouse():Bool
	{
		return (FlxG.mouse.x >= bxl) && (FlxG.mouse.y >= byt) && (FlxG.mouse.y <= byb) && (FlxG.mouse.x <= bxr);
	}
}
