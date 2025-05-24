package backend.util;

import backend.data.ClientPrefs;
import backend.data.Constants;
import flixel.FlxG;
import flixel.util.FlxSave;

/**
 * Utility class for handling and saving user save data.
 */
final class SaveUtil {

    private function new() {}
    
    /**
     * Save ***ALL*** of the user's preferences and progress.
     */
    public static function saveAll() {
        saveUserOptions();
        saveUserControls();
        saveUserProgress();
    }

    /**
     * Saves all of the user's options.
     */
    public static function saveUserOptions():Void {
        // Create and bind the saves
        var optionsSave:FlxSave = new FlxSave();
        optionsSave.bind(Constants.OPTIONS_SAVE_BIND_ID, PathUtil.getSavePath());

        // Assign the data
		optionsSave.data.options = ClientPrefs.getOptions();

        // Save the last volume used
		optionsSave.data.lastVolume = (CacheUtil.isWindowFocused) ? FlxG.sound.volume : CacheUtil.lastVolumeUsed;

        // For checking if the data saved
        var didOptionsSave:Bool = optionsSave.flush();

        // Close the bind
        optionsSave.close();

        // Log if all options were saved
        if (didOptionsSave) 
            FlxG.log.add('All options have been saved!');
        else 
            FlxG.log.warn('All options failed to save.');
    }

    /**
     * Saves all of the user's controls.
     */
    public static function saveUserControls():Void {
        // Create and bind the saves
        var controlsSave:FlxSave = new FlxSave();
        controlsSave.bind(Constants.CONTROLS_SAVE_BIND_ID, PathUtil.getSavePath());

        // Assign the data
		controlsSave.data.keyboard = ClientPrefs.getBinds();

        // For checking if the data saved
        var didControlsSave:Bool = controlsSave.flush();

        // Close the bind
        controlsSave.close();

        // Log if all settings were saved
        if (didControlsSave)
            FlxG.log.add('All controls have been saved!');
        else
            FlxG.log.warn('All controls failed to save.');
    }

    /**
     * Saves all of the user's progress.
     */
    public static function saveUserProgress():Void {
        // Create and bind the save
        var progressSave:FlxSave = new FlxSave();
        progressSave.bind(Constants.PROGRESS_SAVE_BIND_ID, PathUtil.getSavePath());

        // Assign the data
        // TODO: Add later lol

        // For checking if the data saved
        var didProgressSave:Bool = progressSave.flush();

        // Close the bind
        progressSave.close();

        // Log if all progress was saved
        if (didProgressSave)
            FlxG.log.add('All progress has been saved!');
        else
            FlxG.log.warn('All progress failed to save.');
    }

    /**
     * Loads all of the user's progress.
     */
    public static function loadUserProgress():Void {
        // Create and bind the save
        var progressSave:FlxSave = new FlxSave();
        progressSave.bind(Constants.PROGRESS_SAVE_BIND_ID, PathUtil.getSavePath());

        // Assign the data
        // TODO: Do later :p

        // Close the bind
        progressSave.close();
    }

    /**
     * Deletes ***ALL*** of the user save data.
     */
    public static function deleteAll():Void {
        // Create and bind the saves
        var optionsSave:FlxSave = new FlxSave();
        var controlsSave:FlxSave = new FlxSave();
        var progressSave:FlxSave = new FlxSave();

        // Connect to the saves
        optionsSave.bind(Constants.OPTIONS_SAVE_BIND_ID, PathUtil.getSavePath());
        controlsSave.bind(Constants.CONTROLS_SAVE_BIND_ID, PathUtil.getSavePath());
        progressSave.bind(Constants.PROGRESS_SAVE_BIND_ID, PathUtil.getSavePath());

        // Delete the data
        optionsSave.erase();
        controlsSave.erase();
        progressSave.erase();

        // Ensure the data is deleted
        optionsSave.flush();
        controlsSave.flush();
        progressSave.flush();

        // Close the binds
        optionsSave.close();
        controlsSave.close();
        progressSave.close();

        // Log that all data has been deleted
        FlxG.log.add('All user data has been deleted.');
    }
}
