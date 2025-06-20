package starcore.backend.util;

import starcore.backend.data.Constants;
import starcore.entity.Entity;

/**
 * Utility class for handling and modifying entities in
 * the world of Starcore.
 */
final class EntityUtil
{
	function new() {}

	/**
	 * Get an entity by its ID.
	 * 
	 * @param id      The ID of the entity to get.
	 * @return        The entity with the given ID, or null if not found.
	 */
	public static function getEntityById(id:String):Entity
	{
		for (entity in CacheUtil.registeredEntities)
		{
			if (entity.id == id)
			{
				return entity;
			}
		}
		return null;
	}

	/**
	 * Checks if a name is valid for either an entity or item.
	 * 
	 * @param name  The name of the entity/item.
	 * @return      If the name has no invalid characters. 
	 */
	public static function isValidName(name:String):Bool
	{
		for (i in 0...name.length)
		{
			var char:String = name.charAt(i);
			if (Constants.VALID_ITEM_ENTITY_NAME_CHARACTERS.indexOf(char) == -1)
			{
				return false;
			}
		}
		return true;
	}
}
