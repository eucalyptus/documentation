<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Cell renderer
 * 
 * @author serban
 *
 */
interface ICellRenderer{
	/**
	 * Render cell for field with the specied value
	 * 
	 * @param String $fieldName
	 * @param Stringe $fieldValue
	 */
	function render($fieldName,$fieldValue);	
	function setAName($name);
}
?>