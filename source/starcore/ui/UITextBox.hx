package starcore.ui;

import flixel.text.FlxInputTextManager.MoveCursorAction;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import starcore.backend.util.DataUtil;

using StringTools;

/**
 * A more enhanced `FlxInputText`, including all standard keybinds,
 * a text hint display, and more.
 */
class UITextBox extends FlxSpriteGroup
{
	//
	// DISPLAY OBJECTS
	// ================================

	/**
	 * The text that the user sees.
	 */
	public var inputTextObject:FlxInputText;

	var textHintObject:FlxText;

	//
	// DATA
	// =========================
	var textHint:String = '';

	/**
	 * @param x             The X position of `this` text box.
	 * @param y             The Y position of `this` text box.
	 * @param width         The visible width of `this` text box.
	 * @param size          The size of `this` text box.
	 * @param font          The font for the display text. If `null` is passed down, then
	 *                      the default font is used instead.
	 * @param textHint      A somewhat visible text that is supposed to "hint" what
	 *                      the user is meant to type in the textbox.
	 * @param letterSpacing How much spacing there is in between the text.
	 */
	public function new(x:Float, y:Float, width:Int, size:Int, ?font:String, textHint:String = '', letterSpacing:Float = 0.0)
	{
		super();

		this.textHint = textHint;

		// TODO: Figure out a way to implement CTRL + LEFT/RIGHT instead of ALT + LEFT/RIGHT
		inputTextObject = new FlxInputText();
		inputTextObject.text = '';
		inputTextObject.color = FlxColor.BLACK;
		inputTextObject.font = font;
		inputTextObject.size = size;
		inputTextObject.fieldWidth = width;
		inputTextObject.wordWrap = false;
		inputTextObject.textField.multiline = false;
		inputTextObject.letterSpacing = letterSpacing;
		inputTextObject.setPosition(x, y);
		inputTextObject.onTextChange.add((text:String, change:FlxInputTextChange) ->
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				if (change == BACKSPACE_ACTION)
				{
					ctrlDeleteTextAction(WORD_LEFT);
				}
				else if (change == DELETE_ACTION)
				{
					ctrlDeleteTextAction(WORD_RIGHT);
				}
			}
		});
		add(inputTextObject);

		textHintObject = new FlxText();
		textHintObject.text = textHint;
		textHintObject.color = FlxColor.BLACK;
		textHintObject.font = font;
		textHintObject.size = size;
		textHintObject.alpha = 0.5;
		textHintObject.fieldWidth = width;
		textHintObject.wordWrap = false;
		textHintObject.textField.multiline = false;
		textHintObject.letterSpacing = letterSpacing;
		textHintObject.setPosition(x, y);
		add(textHintObject);
	}

	//
	// FUNCTION OVERRIDES
	// ======================================

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// TODO: Figure out an alternative way to show the text cursor when hovered over!

		textHintObject.text = textHint;
		textHintObject.color = inputTextObject.color;
		textHintObject.font = inputTextObject.font;
		textHintObject.size = inputTextObject.size;
		textHintObject.alpha = (inputTextObject.text == '') ? 0.5 : 0;
		textHintObject.fieldWidth = inputTextObject.fieldWidth;
		textHintObject.wordWrap = inputTextObject.wordWrap;
		textHintObject.textField.multiline = inputTextObject.multiline;
		textHintObject.letterSpacing = inputTextObject.letterSpacing;
		textHintObject.setPosition(inputTextObject.x, inputTextObject.y);
	}

	//
	// GETTERS & SETTERS
	// =================================================

	/**
	 * Gets the value of `this` input text's value.
	 * 
	 * @param defaultValue The value to return if the text for the input text field is empty.
	 * @return             The text of `this` input text as a `String` (or as a
	 *                     `Float` if the filter mode is set to `FlxInputTextFilterMode.NUMERIC`).
	 */
	public function getValue(defaultValue:Dynamic):Dynamic
	{
		var text:String = inputTextObject.text;
		if (text != '')
		{
			return (inputTextObject.filterMode != NUMERIC) ? text : Std.parseFloat(text);
		}
		else
		{
			return defaultValue;
		}
	}

	//
	// UTIL FUNCTIONS
	// =============================================

	inline function isHoveredOver():Bool
	{
		return (FlxG.mouse.x >= inputTextObject.x)
			&& (FlxG.mouse.y >= inputTextObject.y)
			&& (FlxG.mouse.y <= inputTextObject.y + inputTextObject.height)
			&& (FlxG.mouse.x <= inputTextObject.x + inputTextObject.width);
	}

	function ctrlDeleteTextAction(dir:MoveCursorAction):Void
	{
		var indexes:Array<Int> = createSelectedWordIndex(dir);
		inputTextObject.text = DataUtil.deleteTextFromString(inputTextObject.text, indexes[0], indexes[1]);
	}

	// For highlighting a word in the correct direction
	function createSelectedWordIndex(dir:MoveCursorAction):Array<Int>
	{
		var curChar:String = '';
		var deleteStartIndex:Int = inputTextObject.caretIndex;
		var deleteEndIndex:Int = inputTextObject.caretIndex;
		var textLength:Int = inputTextObject.text.length;
		while (!(deleteStartIndex < 0 || deleteStartIndex > textLength) && curChar != ' ')
		{
			curChar = inputTextObject.text.charAt(deleteStartIndex);
			deleteStartIndex += (dir == WORD_LEFT) ? -1 : 1;
		}
		// If the start index is not at the start/end of the text box, then
		// add two to ensure we delete text but leave a space at the end 
		if (deleteStartIndex < 0)
		{
			deleteStartIndex = 0;
		}
		else if (deleteStartIndex > textLength)
		{
			deleteStartIndex = textLength;
		}
		// Parenthesis for reading the ternaries more easily
		deleteStartIndex += ((dir == WORD_LEFT) ? ((deleteStartIndex != 0) ? 2 : 0) : ((deleteStartIndex != textLength) ? -2 : 0));
		return [deleteStartIndex, deleteEndIndex];
	}
}
