# How to Contribute

Since Starcore isn't that big of a game yet, things are somewhat simple.
All we ask is that you follow the basic rules and have common sense.

When you write code, heres some simple things we ask of you:

## Issues

If you wish to fix a bug, make an enhancement, or even wish to
simply make a recommendation, then no worries! You can make an [issue](https://github.com/korithekoder/Starcore/issues)
or create a sub-issue and help someone with an issue that needs to be worked on!

> [!IMPORTANT]
> Make sure to set the base branch to `develop` on your pull request or otherwise ***it will NOT be merged and accepted!!***

## Comments & Formatting

Comments are very valuable because they allow you and other
programmers to easily understand what is happening in your code.

However, sometimes they can be a hindrance as well.

If your comments have typos, aren't clear or concise, or just
hard to understand in general, then they won't be any
use. Even too many comments can make it difficult to understand your code.

For doc comments, it's generally not advised to create them for
private variables/functions/typedefs/etc., since they can only be accessed
in the class or file they were made in; however, if there is a private attribute that
you feel needs explaining, go ahead and document it! More likely than not we'll accept
the change, since we (clearly) really value documentation.

### Example of GOOD Comments (With Good Formatting)

```haxe
/**
 * Gets the last key that was pressed on the current frame.
 * 
 * @return The last key that was pressed. If no keys were pressed, then
 *         `FlxKey.NONE` is returned instead.
 */
public static function getLastKeyPressed():FlxKey
{
    for (key in 8...303) // Loop through all keys in FlxKey
    {
        try
        {
            if (FlxG.keys.anyJustPressed([key]))
            {
                return key;
            }
        }
        catch (e:Exception)
        {
            // Skip and move on if it is not a valid key
        }
    }
    return FlxKey.NONE;
}
```

### Example of BAD Comments (With Bad Formatting)

```haxe

/**
 * gets the last key or whatever that was pressed
 * return the last thing pressed lolz
 */
public 
static 
function getLastpressed():FlxKey
{
    // loop thouhg all keys (8-303)
    for (key in 8...303) // loop through all keys
    {
        // try to check if its pressed :p
        try{
            // check if its pressed
            if (FlxG.keys.anyJustPressed([key]))
        {
                // return the pressed key
                    return key;
            }
        }
        // catch the exception
        catch (e:Exception) {
            // just skip with non valid key xd
    }
    }
    // return nnoe if no kyes are pressed
    return FlxKey.NONE;
}
```

> [!TIP]
> You can format a file on VS Code with `SHIFT` + `ALT` + `F` to match the code style standards, 
> although just know that it won't fix typos or correct your grammar, thats all on you!

## Things You CANNOT Do

1. Excluding *collaborators*, there are some files that contributors simply cannot change or delete.

    - You are not allowed to change or delete these files:
        - Any files in the [.vscode folder](.vscode/) (unless you want to add a new word to filter the spell checker,
          do so by adding a word to the list in the `cSpell.words` array inside of `settings.json` file).
        - Any files in the [setup folder](setup/).
        - Any files in the [unused folder](unused/), that's for the collaborators!
        - [`.gitattributes`](.gitattributes/)
        - [`.gitignore`](.gitignore/)
        - [`.prettierignore`](.prettierignore/)
        - [`.prettierrc.js`](.prettierrc.js/)
        - [`checkstyle.json`](checkstyle.json/)
        - [`COMPILING.md`](COMPILING.md/)
        - [`CONTRIBUTING.md`](CONTRIBUTING.md/)
        - [`hxformat.json`](hxformat.json/)
        - [`LICENSE.md`](LICENSE.md/)
        - [`project.hxp`](project.hxp/)
        - [`README.md`](README.md/)
